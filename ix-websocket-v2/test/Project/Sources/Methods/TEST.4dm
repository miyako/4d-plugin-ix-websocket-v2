//%attributes = {}
CALL WORKER:C1389(1; Formula:C1597(CB_FORM).source)

Websocket SET METHOD("CB")

$options:=New object:C1471
$options.URL:="wss://demo.piesocket.com/v3/channel_1?api_key=oCdCMcMPQpbvNjUIzqtvF1d2X2okWpDQj4AwARJuAgtjhzKxVEjQU6IdCjwm&notify_self"

$client:=Websocket client($options)

$client.timeout:=10  //sec
$status:=Websocket client start($client)

$options:=New object:C1471
$client.message:="hello world"

var $data : Blob

$status:=Websocket client send($client)

$status:=Websocket client stop($client)
