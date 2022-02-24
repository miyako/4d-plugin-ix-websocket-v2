![version](https://img.shields.io/badge/version-17%2B-3E8B93)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm%20|%20win-64&color=blue)
[![license](https://img.shields.io/github/license/miyako/4d-plugin-ix-websocket-v2)](LICENSE)
![downloads](https://img.shields.io/github/downloads/miyako/4d-plugin-ix-websocket-v2/total)

# 4d-plugin-ix-websocket-v2
Simple websocket based on [IXWebSocket-11.0.8](https://github.com/machinezone/IXWebSocket/releases/tag/v11.0.8)

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
|socket|Object||
|socket.id|Number|unique identifier|

not implemented: 

* setTLSOptions
* setPerMessageDeflateOptions
* addSubProtocol

## Websocket client start

conenct and run client object

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

also any `Websocket client` property can be modified

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
|status|Object|not used|

## Websocket client send

send message

```4d
status:=Websocket client send(socket{; data})
```

|Parameter|Type|Description|
|-|-|-|
|socket|Object||
|socket.id|Number|socket unique identifier|
|socket.message|Text|optional|
|data|BLOB||
|status|Object||
|status.success|Boolean||
|status.compressionError|Boolean||
|status.payloadSize|Boolean||
|status.wireSize|Boolean||

`data` is sent as binary if `message` is not passed.

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
