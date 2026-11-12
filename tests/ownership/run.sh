#!/bin/sh
# Build the real plugin sources + bundled SDK against the synthetic engine
# with ASan/UBSan, then run the ownership regressions.
#   tests/ownership/run.sh [SOURCE_ROOT] [expected-failure ...]
# SOURCE_ROOT defaults to this checkout; pass another tree (e.g. a git archive
# of an older commit) to run this same harness against its sources.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "${1:-$here/../..}" && pwd)
[ $# -gt 0 ] && shift
src="$root/ix-websocket-v2"
out=$(mktemp -d)
trap 'rm -rf "$out"' EXIT
api="$src/4D Plugin API"
flags="-g -O1 -fno-omit-frame-pointer -fsanitize=address,undefined -fno-sanitize-recover=undefined -fno-objc-arc -Wno-deprecated-declarations -Wno-multichar -w"
build() { clang++ $flags -I"$api" -I"$api/Classes" -I"$src/support" -I"$src" -I"$src/include" -I"$here" -std=c++17 -c "$@"; }
build -x objective-c++ "$api/4DPluginAPI.c" -o "$out/api.o"
build -x objective-c++ "$api/Classes/C_TEXT.cpp" -o "$out/ctext.o"
build -x objective-c++ "$api/Classes/C_BLOB.cpp" -o "$out/cblob.o"
build -x objective-c++ "$api/Classes/C_LONGINT.cpp" -o "$out/clongint.o"
build -x objective-c++ "$src/support/4DPlugin-JSON.cpp" -o "$out/json.o"
build -x c++ "$here/fake_engine.cpp" -o "$out/engine.o"
build -x objective-c++ "$here/harness.mm" -o "$out/harness.o" # includes 4DPlugin-ix-websocket.cpp
# committed universal static libraries; never connected (no network)
clang++ $flags "$out"/*.o -o "$out/harness" \
    "$src/a/libixwebsocket.a" "$src/a/libjsoncpp.a" "$src/a/libssl.a" "$src/a/libcrypto.a" -lz \
    -framework Cocoa -framework Security -framework CoreFoundation
ASAN_OPTIONS=abort_on_error=0:halt_on_error=1:detect_leaks=0 UBSAN_OPTIONS=print_stacktrace=1 "$out/harness" "$@"
