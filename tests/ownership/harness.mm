// Ownership regressions for the ix-websocket plugin's 4D variable/object
// handling. Unity build of the real plugin source plus the real SDK and
// support/4DPlugin-JSON.cpp, running against tests/ownership/fake_engine
// instead of 4D. Sockets and servers are real IXWebSocket objects that are
// never connected or started: no network traffic is generated.
// Usage: harness [expected-failure ...]  (names of tests that must fail)
#include <algorithm>
#include <array>
#include <atomic>
#include <chrono>
#include <condition_variable>
#include <functional>
#include <iostream>
#include <list>
#include <map>
#include <memory>
#include <mutex>
#include <queue>
#include <set>
#include <sstream>
#include <string>
#include <thread>
#include <tuple>
#include <unordered_map>
#include <utility>
#include <vector>
#include <openssl/ssl.h>
#include "json/json.h"
// Test-only access to WebSocketServer::_clients so a server can hold an
// unconnected client without listening or accepting a connection.
#define private public
#include <ixwebsocket/IXWebSocketServer.h>
#undef private
#include "4DPlugin-ix-websocket.cpp"
#include "fake_engine.h"
#include <cstdio>

using namespace fake4d;

static std::vector<std::string> gFailures;
#define CHECK(cond) do { if (!(cond)) gFailures.push_back(#cond); } while (0)

static void attach(Obj *parent, const char *key, Obj *child) { put_ref(parent, key, child); release(child); }

// Runs a plugin command with options as its object parameter; returns the
// command's returned object (owned by the caller).
static Obj *command(void (*fn)(PA_PluginParameters), Obj *options) {
    PA_ObjectRef opt = (PA_ObjectRef)options;
    PA_ObjectRef *slots[1] = {&opt};
    PA_ObjectRef result = nullptr;
    PluginBlock block = {slots, &result, nullptr};
    fn(&block);
    return (Obj *)result;
}

static void listener(const char *method, const char *data) {
    IXWS::MESSAGE_TYPE.push_back((int)ix::WebSocketMessageType::Message);
    IXWS::MESSAGE_DATA.push_back(data);
    IXWS::WEBSOCKET_ID.push_back(1);
    CUTF16String m;
    for (const char *p = method; *p; ++p) m.push_back((PA_Unichar)*p);
    IXWS::LISTENER_METHOD.setUTF16String(&m);
    listenerLoopExecuteMethod();
    IXWS::LISTENER_METHOD.setUTF16String((PA_Unichar *)"\0\0", 0);
}

// Creates an unstarted server through the plugin; returns its options object.
static Obj *new_server(bool with_client) {
    Obj *opts = new_object();
    release(command(Websocket_server, opts));
    if (with_client) {
        ix::WebSocketServer *server = _serverGet((socket_id_t)ob_get_n((PA_ObjectRef)opts, L"id"));
        std::shared_ptr<ix::WebSocket> client = std::make_shared<ix::WebSocket>();
        client->setUrl("/chat");
        std::lock_guard<std::mutex> lock(server->_clientsMutex);
        server->_clients.insert(client);
    }
    return opts;
}

static void clear_server(Obj *opts) {
    Obj *r = command(Websocket_server_clear, opts);
    CHECK(ob_get_b((PA_ObjectRef)r, L"success"));
    release(r);
    release(opts);
}

static Obj *send_options(Obj *server_opts) {
    Obj *opts = new_object();
    put_real(opts, "id", ob_get_n((PA_ObjectRef)server_opts, L"id"));
    put_string(opts, "message", "hello");
    return opts;
}

static size_t collection_length(Obj *o, const char *key) {
    Obj *c = get_ref(o, key);
    return c ? element_count(c) : (size_t)-1;
}

struct Test { const char *name; std::function<void()> body; };

static const Test kTests[] = {
    // --- LIVE: listenerLoopExecuteMethod (every callback event) ---
    {"live_listener_byid_params_no_leak", [] {
        set_method("cb", 7, nullptr);
        listener("cb", "{}");
        CHECK(method_calls() == 1);
    }},
    {"live_listener_execute_method_params_no_leak", [] {
        set_method("other", 7, nullptr); // "cb" has no ID: EXECUTE METHOD (1007) path
        listener("cb", "{}");
        CHECK(method_calls() == 1);
        CHECK(last_execute_method_name() == "cb");
        CHECK(last_execute_method_params() == 4);
    }},
    // --- LIVE: support/4DPlugin-JSON.cpp getters (every command's options) ---
    {"live_ob_get_s_released", [] {
        Obj *o = new_object();
        put_string(o, "k", "hello");
        CUTF8String s;
        CHECK(ob_get_s((PA_ObjectRef)o, L"k", &s));
        CHECK(s == CUTF8String((const uint8_t *)"hello"));
        release(o);
    }},
    {"live_ob_get_a_released", [] {
        Obj *o = new_object();
        put_string(o, "k", "hi");
        CUTF16String s;
        CHECK(ob_get_a((PA_ObjectRef)o, L"k", &s));
        CHECK(s.length() == 2 && s[0] == 'h' && s[1] == 'i');
        release(o);
    }},
    {"live_ob_get_b_n_nonmatching_released", [] {
        Obj *o = new_object();
        put_string(o, "tls", "yes"); put_string(o, "port", "1");
        CHECK(!ob_get_b((PA_ObjectRef)o, L"tls"));
        CHECK(ob_get_n((PA_ObjectRef)o, L"port") == 0.0);
        release(o);
    }},
    {"live_ob_get_o_borrowed", [] {
        Obj *o = new_object(), *c = new_object();
        put_ref(o, "headers", c);
        CHECK(ob_get_o((PA_ObjectRef)o, L"headers") == (PA_ObjectRef)c);
        CHECK(refcount(c) == 2); // test + parent: the parent keeps the borrowed ref alive
        release(c); release(o);
        CHECK(refcount(c) == 0);
    }},
    {"live_ob_get_c_borrowed", [] {
        Obj *o = new_object(), *c = new_object(true);
        put_ref(o, "uri", c);
        CHECK(ob_get_c((PA_ObjectRef)o, L"uri") == (PA_CollectionRef)c);
        CHECK(refcount(c) == 2);
        release(c); release(o);
        CHECK(refcount(c) == 0);
    }},
    {"live_ob_get_o_c_nonmatching_released", [] {
        Obj *o = new_object();
        put_string(o, "headers", "x");
        CHECK(ob_get_o((PA_ObjectRef)o, L"headers") == nullptr);
        CHECK(ob_get_c((PA_ObjectRef)o, L"headers") == nullptr);
        release(o);
    }},
    // --- LIVE: Websocket client (configureClient headers, URL) ---
    {"live_client_headers_no_leak", [] {
        Obj *opts = new_object(), *headers = new_object();
        put_string(opts, "URL", "ws://127.0.0.1:9/");
        put_string(headers, "X-Test", "1");
        put_ref(opts, "headers", headers);
        Obj *r = command(Websocket_client, opts);
        CHECK(ob_get_n((PA_ObjectRef)r, L"id") > 0);
        CHECK(refcount(headers) == 2); // the caller's headers object is borrowed, not released
        ix::WebSocket *ws = _socketGet((socket_id_t)ob_get_n((PA_ObjectRef)opts, L"id"));
        CHECK(ws != nullptr && ws->getUrl() == "ws://127.0.0.1:9/");
        release(r);
        r = command(Websocket_client, opts); // get info
        std::string state;
        CHECK(get_string(r, "readyState", &state) && state == "closed");
        release(r);
        r = command(Websocket_client_clear, opts);
        CHECK(ob_get_b((PA_ObjectRef)r, L"success"));
        release(r);
        release(headers); release(opts);
        CHECK(refcount(headers) == 0);
    }},
    // --- LIVE: Websocket server send / get info ---
    {"live_server_send_uri_collection_no_leak", [] {
        Obj *server = new_server(false), *opts = send_options(server), *uri = new_object(true);
        push_string(uri, "/chat");
        attach(opts, "uri", uri);
        Obj *r = command(Websocket_server_send, opts);
        CHECK(collection_length(r, "statuses") == 0);
        CHECK(refcount(uri) == 1);
        release(r); release(opts);
        clear_server(server);
    }},
    {"live_server_send_uri_text_no_leak", [] {
        Obj *server = new_server(false), *opts = send_options(server);
        put_string(opts, "uri", "/chat");
        Obj *r = command(Websocket_server_send, opts);
        CHECK(collection_length(r, "statuses") == 0);
        release(r); release(opts);
        clear_server(server);
    }},
    {"live_server_send_status_no_leak", [] {
        Obj *server = new_server(true), *opts = send_options(server);
        Obj *r = command(Websocket_server_send, opts);
        CHECK(collection_length(r, "statuses") == 1);
        release(r); release(opts);
        clear_server(server);
    }},
    {"live_server_get_info_no_leak", [] {
        Obj *server = new_server(true);
        Obj *r = command(Websocket_server, server);
        CHECK(collection_length(r, "clients") == 1);
        release(r);
        clear_server(server);
    }},
    {"live_server_send_element_error_skipped", [] {
        Obj *server = new_server(false), *opts = send_options(server), *uri = new_object(true);
        push_string(uri, "/a"); push_string(uri, "/b");
        attach(opts, "uri", uri);
        fail_next_gets(2, true); // poisoned element values must be skipped, not cleared
        Obj *r = command(Websocket_server_send, opts);
        release(r); release(opts);
        clear_server(server);
    }},
    // --- LIVE: setters that seed an empty owned string before a shallow set ---
    {"live_ob_set_s_no_leak", [] {
        Obj *o = new_object();
        ob_set_s((PA_ObjectRef)o, L"readyState", "open"); // wide key: get info, errorStr
        ob_set_s((PA_ObjectRef)o, "X-Key", "v");          // narrow key: client start headers
        std::string got;
        CHECK(get_string(o, "readyState", &got) && got == "open");
        CHECK(get_string(o, "X-Key", &got) && got == "v");
        release(o);
    }},
    // --- HARDENING: unproven in 4D (SDK pre-sets the result to Undefined) ---
    {"hardening_listener_byid_result_released", [] {
        set_method("cb", 7, "returned"); // engine hands back an owned return value
        listener("cb", "{}");
        CHECK(method_calls() == 1);
    }},
    // --- DORMANT: helpers with no consumer in this plugin ---
    {"dormant_ob_set_a_no_leak", [] {
        Obj *o = new_object();
        CUTF16String u16;
        u16.push_back('w');
        ob_set_a((PA_ObjectRef)o, L"a", L"z");
        ob_set_a((PA_ObjectRef)o, L"b", &u16);
        std::string got;
        CHECK(get_string(o, "a", &got) && got == "z");
        CHECK(get_string(o, "b", &got) && got == "w");
        release(o);
    }},
    {"dormant_ob_set_p_no_leak", [] {
        Obj *o = new_object();
        PA_Picture p = PA_CreatePicture(nullptr, 0);
        ob_set_p((PA_ObjectRef)o, L"p", p); // consumes p, like ob_set_o/ob_set_c
        CHECK(has_picture(o, "p"));
        release(o);
    }},
    {"dormant_ob_get_d_released", [] {
        Obj *o = new_object();
        put_date(o, "d", 3, 4, 2024);
        put_string(o, "s", "x");
        short d = 0, m = 0, y = 0;
        CHECK(ob_get_d((PA_ObjectRef)o, L"d", &d, &m, &y) && d == 3 && m == 4 && y == 2024);
        CHECK(!ob_get_d((PA_ObjectRef)o, L"s", &d, &m, &y));
        release(o);
    }},
    // --- controls: must pass before and after ---
    {"control_getters_error_not_cleared", [] {
        Obj *o = new_object();
        put_string(o, "s", "x"); put_real(o, "n", 1); put_bool(o, "b", true); put_date(o, "d", 1, 1, 2024);
        CUTF8String s;
        CUTF16String a;
        short d, m, y;
        fail_next_gets(1); ob_get_s((PA_ObjectRef)o, L"s", &s);
        fail_next_gets(1); ob_get_a((PA_ObjectRef)o, L"s", &a);
        fail_next_gets(1); CHECK(ob_get_n((PA_ObjectRef)o, L"n") == 0.0);
        fail_next_gets(1); CHECK(!ob_get_b((PA_ObjectRef)o, L"b"));
        fail_next_gets(1); ob_get_d((PA_ObjectRef)o, L"d", &d, &m, &y);
        fail_next_gets(1); CHECK(ob_get_o((PA_ObjectRef)o, L"s") == nullptr);
        fail_next_gets(1); CHECK(ob_get_c((PA_ObjectRef)o, L"s") == nullptr);
        release(o);
    }},
    {"control_scalar_getters", [] {
        Obj *o = new_object();
        put_real(o, "n", 2.5); put_bool(o, "b", true);
        CHECK(ob_get_n((PA_ObjectRef)o, L"n") == 2.5);
        CHECK(ob_get_b((PA_ObjectRef)o, L"b"));
        CHECK(ob_get_n((PA_ObjectRef)o, L"missing") == 0.0);
        CHECK(ob_is_defined((PA_ObjectRef)o, L"n"));
        CHECK(!ob_is_defined((PA_ObjectRef)o, L"missing"));
        release(o);
    }},
    {"control_consuming_setters", [] {
        Obj *o = new_object(), *child = new_object(), *coll = new_object(true);
        ob_set_n((PA_ObjectRef)o, L"n", 1); ob_set_b((PA_ObjectRef)o, L"t", true);
        ob_set_0((PA_ObjectRef)o, L"z"); ob_set_i((PA_ObjectRef)o, L"i", 3);
        ob_set_o((PA_ObjectRef)o, L"o", (PA_ObjectRef)child);      // consumes the caller's reference
        ob_set_c((PA_ObjectRef)o, L"c", (PA_CollectionRef)coll);   // consumes the caller's reference
        CHECK(refcount(child) == 1 && refcount(coll) == 1);
        release(o);
        CHECK(refcount(child) == 0 && refcount(coll) == 0);
    }},
    {"control_listener_no_method", [] {
        listener("", "{}");
        CHECK(method_calls() == 0);
    }},
};

int main(int argc, char **argv) {
    install();
    std::set<std::string> expected(argv + 1, argv + argc);
    int unexpected = 0, passed = 0, xfailed = 0;
    for (const Test &t : kTests) {
        reset();
        gFailures.clear();
        size_t strings = live_strings(), handles = live_handles(), objects = live_objects(),
               pictures = live_pictures();
        t.body();
        for (auto &v : violations()) gFailures.push_back("engine: " + v);
        if (live_strings() != strings)
            gFailures.push_back("leaked strings: " + std::to_string((long)(live_strings() - strings)));
        if (live_handles() != handles)
            gFailures.push_back("leaked handles: " + std::to_string((long)(live_handles() - handles)));
        if (live_objects() != objects)
            gFailures.push_back("leaked objects: " + std::to_string((long)(live_objects() - objects)));
        if (live_pictures() != pictures)
            gFailures.push_back("leaked pictures: " + std::to_string((long)(live_pictures() - pictures)));
        bool failed = !gFailures.empty();
        bool want = expected.erase(t.name) > 0;
        const char *verdict = failed ? (want ? "XFAIL" : "FAIL") : (want ? "XPASS" : "PASS");
        printf("%-5s %s\n", verdict, t.name);
        for (auto &f : gFailures) printf("      %s\n", f.c_str());
        if (failed != want) unexpected++;
        else if (failed) xfailed++;
        else passed++;
    }
    for (auto &name : expected) { printf("UNKNOWN expected failure %s\n", name.c_str()); unexpected++; }
    printf("passed=%d xfailed=%d unexpected=%d\n", passed, xfailed, unexpected);
    printf("%s\n", unexpected ? "RESULT: UNEXPECTED" : "RESULT: OK");
    return unexpected ? 1 : 0;
}
