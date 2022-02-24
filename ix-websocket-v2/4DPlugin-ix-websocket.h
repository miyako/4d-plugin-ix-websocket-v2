/* --------------------------------------------------------------------------------
 #
 #	4DPlugin-ix-websocket.h
 #	source generated by 4D Plugin Wizard
 #	Project : ix-websocket
 #	author : miyako
 #	2022/02/24
 #  
 # --------------------------------------------------------------------------------*/

#ifndef PLUGIN_IX_WEBSOCKET_H
#define PLUGIN_IX_WEBSOCKET_H

#include "4DPluginAPI.h"

#include <ixwebsocket/IXNetSystem.h>
#include <ixwebsocket/IXWebSocket.h>
#include <ixwebsocket/IXUserAgent.h>
#include <iostream>

#include <mutex>

void listenerInit(void);
void listenerLoop(void);
void listenerLoopStart(void);
void listenerLoopFinish(void);
void listenerLoopExecute(void);
void listenerLoopExecuteMethod(void);

typedef PA_long32 process_number_t;
typedef PA_long32 process_stack_size_t;
typedef PA_long32 method_id_t;
typedef PA_Unichar* process_name_t;

typedef PA_long32 socket_id_t;

static bool IsProcessOnExit();
static void OnStartup();
static void OnCloseProcess();

#include "C_TEXT.h"
#include "C_BLOB.h"

#include "4DPlugin-JSON.h"

#include "json/json.h"

#pragma mark -

void Websocket_client(PA_PluginParameters params);
void Websocket_server(PA_PluginParameters params);
void Websocket_client_start(PA_PluginParameters params);
void Websocket_server_start(PA_PluginParameters params);
void Websocket_client_stop(PA_PluginParameters params);
void Websocket_server_stop(PA_PluginParameters params);
void Websocket_client_send(PA_PluginParameters params);
void Websocket_server_send(PA_PluginParameters params);
void Websocket_client_clear(PA_PluginParameters params);
void Websocket_server_clear(PA_PluginParameters params);
void Websocket_server_clients(PA_PluginParameters params);
void Websocket_Get_method(PA_PluginParameters params);
void Websocket_SET_METHOD(PA_PluginParameters params);

#endif /* PLUGIN_IX_WEBSOCKET_H */