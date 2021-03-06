![version](https://img.shields.io/badge/version-18%2B-EB8E5F)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm%20|%20win-64&color=blue)

# 4d-plugin-ix-websocket-v2
Simple websocket based on [IXWebSocket-11.0.8](https://github.com/machinezone/IXWebSocket/releases/tag/v11.0.8)

### build notes

on Mac, add `USE_OPEN_SSL`. TLS is not supported with [AppleSSL backend](https://machinezone.github.io/IXWebSocket/design/).   

## Websocket SET METHOD

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
|options.URL|Text||
|options.headers|Object|optional, KVP|
|options.pingInterval|Number|optional, seconds|
|options.enableAutomaticReconnection|Boolean|optional, true by default|
|options.enablePong|Boolean|optional|
|options.enablePerMessageDeflate|Boolean|optional|
|options.maxWaitBetweenReconnectionRetries|Number|optional, milliseconds|
|options.certFile|Text|optional, PEM|
|options.keyFile|Text|optional, PEM|
|options.caFile|Text|optional, PEM|
|options.ciphers|Text|optional|
|options.tls|Boolean|optional|
|socket|Object||
|socket.id|Number|unique identifier (positive)|

if `id` is passed in `options`, information is returned instead of creating a new client object.

|Parameter|Type|Description|
|-|-|-|
|socket|Object||
|socket.readyState|Text||
|socket.URL|Text||
|socket.perMessageDeflateOptionsEnabled|Boolean||
|socket.automaticReconnectionEnabled|Boolean||
|socket.maxWaitBetweenReconnectionRetries|Number||
|socket.pingInterval|Number||
|socket.bufferedAmount|Number||

## Websocket client start

connect and run client object

```4d
status:=Websocket client start(socket)
```

|Parameter|Type|Description|
|-|-|-|
|socket|Object||
|socket.id|Number|socket unique identifier|
|socket.timeout|Number|optional, `30` seconds by default|
|status|Object||
|status.headers|Object||
|status.http_status|Number||
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
|socket.code|Number|optional|
|socket.reason|Text|optional|
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
|socket.message|Text|optional|
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
|options.port|Number|optional|
|options.backlog|Number|optional|
|options.handshakeTimeoutSecs|Number|optional|
|options.addressFamily|Number|optional|
|options.maxConnections|Number|optional|
|options.host|Text|optional|
|options.enablePong|Boolean|optional|
|options.enablePerMessageDeflate|Boolean|optional|
|options.certFile|Text|optional, PEM|
|options.keyFile|Text|optional, PEM|
|options.caFile|Text|optional, PEM|
|options.ciphers|Text|optional|
|options.tls|Boolean|optional|
|socket|Object||
|socket.id|Number|unique identifier (negative)|

if `id` is passed in `options`, information is returned instead of creating a new server object.

|Parameter|Type|Description|
|-|-|-|
|socket|Object||
|socket.clients|Collection of Text|URLs|
            
## Websocket server start

listen and start server object

```4d
status:=Websocket client start(socket)
```

|Parameter|Type|Description|
|-|-|-|
|socket|Object||
|socket.id|Number|socket unique identifier|
|status|Object||
|status.headers|Object||
|status.http_status|Number||
|status.success|Boolean||
|status.uri|Text||
|status.errorStr|Text|on failure|

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
|status|Object|information (same as `Websocket server`)|

## Websocket server send

send message

```4d
status:=Websocket server send(socket)
```

|Parameter|Type|Description|
|-|-|-|
|socket|Object||
|socket.id|Number|socket unique identifier|
|socket.message|Text|optional|
|socket.uri|Text or Collection of Text|optional|
|status|Object||
|status.statuses[]|Collection of Objects||
|status.statuses[].success|Boolean||
|status.statuses[].compressionError|Boolean||
|status.statuses[].payloadSize|Number||
|status.statuses[].wireSize|Number||
|status.statuses[].uri|Text||

by default, message is sent to all connected clients. to target a specific client, pass `uri`

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
