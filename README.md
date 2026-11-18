![version](https://img.shields.io/badge/version-18%2B-EB8E5F)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm%20|%20win-64&color=blue)

# 4d-plugin-ix-websocket-v2

Simple websocket plugin for 4D, based on [IXWebSocket-11.0.8](https://github.com/machinezone/IXWebSocket/releases/tag/v11.0.8).

**Platforms:** macOS (Intel & Apple silicon, universal binary), Windows 64-bit.

### build notes

on Mac, add `USE_OPEN_SSL`. TLS is not supported with [AppleSSL backend](https://machinezone.github.io/IXWebSocket/design/).

## Commands

|Command|Description|
|-|-|
|`Websocket client`|create client object, or return client info when `id` is passed|
|`Websocket server`|create server object, or return server info when `id` is passed|
|`Websocket client start`|connect client and start it|
|`Websocket server start`|listen and start server|
|`Websocket client stop`|stop client (connection stays alive, can restart)|
|`Websocket server stop`|stop server|
|`Websocket client send`|send a text message from a client|
|`Websocket server send`|send a text message to connected clients|
|`Websocket client clear`|stop and destroy a client object|
|`Websocket server clear`|stop and destroy a server object|
|`Websocket Get method`|return the registered callback method name|
|`Websocket SET METHOD`|register the project method called on websocket events|

## Websocket SET METHOD

Registers a project method invoked on websocket events. The method is called with three parameters: `$1` event type (Integer), `$2` socket id (Integer), `$3` event data (Text, JSON).

callback is invoked for the following events:

* Message(0)
* Open(1)
* Close(2)
* Error(3)

for simplicity, it is **not** called for the following events:

* Ping(4)
* Pong(5)
* Fragment(6)

```4d
Websocket SET METHOD(method)
```

|Parameter|Type|Description|
|-|-|-|
|method|Text|callback project method name|

The `$3` payload is a JSON object whose fields depend on the event type and on whether the event came from a client or a server:

* **Message**: `str` (message text), `binary` (raw binary payload), `wireSize`. Server events also add `uri`, `remoteIp`, `remotePort`.
* **Open**: `uri`, `headers` (object). Server events also add `remoteIp`, `remotePort`.
* **Close**: `code`, `reason`, `remote`. Server events also add `uri`, `remoteIp`, `remotePort`.
* **Error**: `retries`, `wait_time`, `http_status`, `reason`, `decompressionError`.

Client socket ids are positive; server socket ids are negative. If no method is registered, the event is dispatched to 4D command 1007 instead.

## Websocket Get method

```4d
method:=Websocket Get method
```

|Parameter|Type|Description|
|-|-|-|
|method|Text|callback project method name|

## Websocket client

create client object

```4d
socket:=Websocket client(options)
```

|Parameter|Type|Description|
|-|-|-|
|options|Object||
|options.URL|Text|websocket URL, e.g. `wss://host/path` or `ws://host/path`|
|options.headers|Object|optional, KVP extra HTTP headers|
|options.pingInterval|Number|optional, seconds|
|options.enableAutomaticReconnection|Boolean|optional, IXWebSocket default (enabled)|
|options.enablePong|Boolean|optional|
|options.enablePerMessageDeflate|Boolean|optional|
|options.maxWaitBetweenReconnectionRetries|Number|optional, milliseconds|
|options.certFile|Text|optional, path to PEM certificate file|
|options.keyFile|Text|optional, path to PEM private key file|
|options.caFile|Text|optional, path to PEM CA file|
|options.ciphers|Text|optional, OpenSSL cipher list|
|options.tls|Boolean|optional, enable TLS (use `wss://` URLs)|
|socket|Object||
|socket.id|Number|unique identifier (positive)|

if `id` is passed in `options`, information is returned instead of creating a new client object.

|Parameter|Type|Description|
|-|-|-|
|socket|Object||
|socket.readyState|Text|`connecting`, `open`, `closing` or `closed`|
|socket.URL|Text||
|socket.perMessageDeflateOptionsEnabled|Boolean||
|socket.automaticReconnectionEnabled|Boolean||
|socket.maxWaitBetweenReconnectionRetries|Number||
|socket.pingInterval|Number||
|socket.bufferedAmount|Number||

## Websocket client start

connect and run client object. Blocks until connected, failed or `timeout` seconds elapsed.

```4d
status:=Websocket client start(socket)
```

|Parameter|Type|Description|
|-|-|-|
|socket|Object||
|socket.id|Number|socket unique identifier|
|socket.timeout|Number|optional, `30` seconds by default|
|status|Object||
|status.headers|Object|response headers|
|status.http_status|Number|HTTP status of the handshake|
|status.success|Boolean||
|status.uri|Text||
|status.errorStr|Text|on failure|

`Websocket client` property can be modified while the client is stopped

## Websocket client stop

stop client object

```4d
status:=Websocket client stop(socket)
```

|Parameter|Type|Description|
|-|-|-|
|socket|Object||
|socket.id|Number|socket unique identifier|
|socket.code|Number|optional, close code (default `1000`)|
|socket.reason|Text|optional, close reason|
|status|Object|information (same as `Websocket client`)|

## Websocket client send

send message

```4d
status:=Websocket client send(socket)
```

|Parameter|Type|Description|
|-|-|-|
|socket|Object||
|socket.id|Number|socket unique identifier|
|socket.message|Text|optional, message payload|
|status|Object||
|status.success|Boolean||
|status.compressionError|Boolean||
|status.payloadSize|Number||
|status.wireSize|Number||

## Websocket client clear

stop and destroy client object

```4d
status:=Websocket client clear(socket)
```

|Parameter|Type|Description|
|-|-|-|
|socket|Object||
|socket.id|Number|socket unique identifier|
|status|Object||
|status.success|Boolean||

## Websocket server

create server object

```4d
socket:=Websocket server(options)
```

|Parameter|Type|Description|
|-|-|-|
|options|Object||
|options.port|Number|optional, TCP listen port|
|options.backlog|Number|optional, TCP backlog|
|options.handshakeTimeoutSecs|Number|optional|
|options.addressFamily|Number|optional, OS `AF_*` address family constant|
|options.maxConnections|Number|optional|
|options.host|Text|optional, bind address (default all interfaces)|
|options.enablePong|Boolean|optional|
|options.enablePerMessageDeflate|Boolean|optional, enabled by default server-side; `False` disables it|
|options.certFile|Text|optional, path to PEM certificate file|
|options.keyFile|Text|optional, path to PEM private key file|
|options.caFile|Text|optional, path to PEM CA file|
|options.ciphers|Text|optional, OpenSSL cipher list|
|options.tls|Boolean|optional, accept `wss://` connections|
|socket|Object||
|socket.id|Number|unique identifier (negative)|

if `id` is passed in `options`, information is returned instead of creating a new server object.

|Parameter|Type|Description|
|-|-|-|
|socket|Object||
|socket.clients|Collection of Text|URLs of connected clients|

## Websocket server start

listen and start server object

```4d
status:=Websocket server start(socket)
```

|Parameter|Type|Description|
|-|-|-|
|socket|Object||
|socket.id|Number|socket unique identifier|
|status|Object||
|status.success|Boolean||
|status.errStr|Text|on failure|

`Websocket server` property other than `port` `host` `backlog` `maxConnections` `handshakeTimeoutSecs` `addressFamily` can be modified while the server is stopped

## Websocket server stop

stop server object

```4d
status:=Websocket server stop(socket)
```

|Parameter|Type|Description|
|-|-|-|
|socket|Object||
|socket.id|Number|socket unique identifier|
|status|Object||

## Websocket server send

send message

```4d
status:=Websocket server send(socket)
```

|Parameter|Type|Description|
|-|-|-|
|socket|Object||
|socket.id|Number|socket unique identifier|
|socket.message|Text|optional, message payload|
|socket.uri|Text or Collection of Text|optional|
|status|Object||
|status.statuses[]|Collection of Objects||
|status.statuses[].success|Boolean||
|status.statuses[].compressionError|Boolean||
|status.statuses[].payloadSize|Number||
|status.statuses[].wireSize|Number||
|status.statuses[].uri|Text|client URL the status belongs to|

by default, message is sent to all connected clients. to target a specific client, pass `uri` (the client URL, as shown in the Open event `uri` field or in `socket.clients`)

## Websocket server clear

stop and destroy server object

```4d
status:=Websocket server clear(socket)
```

|Parameter|Type|Description|
|-|-|-|
|socket|Object||
|socket.id|Number|socket unique identifier|
|status|Object||
|status.success|Boolean||

## Example

Adapted from `test/Project/Sources/Forms/CLIENT/method.4dm` and `test/Project/Sources/Forms/SERVER/method.4dm` in this repository.

```4d
// client (CLIENT form, On Load)
$options:=New object
$options.URL:="wss://127.0.0.1:8000/api?window="+Form.window
$options.tls:=True
$options.caFile:="NONE"  //otherwise, unknown ca

Form.client:=Websocket client($options)

Form.client.timeout:=10  //sec
$status:=Websocket client start(Form.client)
```

```4d
// server (SERVER form, On Load)
Websocket SET METHOD("CB")

$options:=New object
$options.port:=8000  //port<1023 permission may be denied
$options.host:="127.0.0.1"
$options.maxConnections:=10
$options.tls:=True
$options.caFile:="NONE"  //otherwise, unknown ca

//must be path, not PEM text

$options.certFile:=Folder file("cert.pem").path
$options.keyFile:=Folder file("key.pem").path

Form.server:=Websocket server($options)

$status:=Websocket server start(Form.server)
```

```4d
// callback dispatch (CB.4dm)
#DECLARE($type : Integer; $socket : Integer; $message : Text)

If (Storage.CB#Null)
	CALL FORM("CB_FORM"; $type; $socket; $message)
End if
```

## Error handling & troubleshooting

* Commands never raise 4D errors; check `status.success` and `status.errorStr` / `status.errStr` instead.
* `Websocket client start` blocks for up to `socket.timeout` seconds (default `30`) while connecting.
* TLS options (`certFile`, `keyFile`, `caFile`) take **file paths**, not PEM content. On macOS the build uses OpenSSL; TLS is not supported with the AppleSSL backend.
* If the callback method is not registered with `Websocket SET METHOD`, nothing is called on events.
* Socket ids are integers assigned by the plugin: positive for clients, negative for servers. Pass them back via `options.id` to address an existing object.
* `Websocket client clear` / `Websocket server clear` must be called to release sockets and file descriptors.
