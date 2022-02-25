$event:=FORM Event:C1606

Case of 
	: ($event.code=On Load:K2:1)
		
		Form:C1466.CB:=New object:C1471("col"; New collection:C1472; "sel"; Null:C1517; "item"; Null:C1517; "pos"; Null:C1517)
		
		Websocket SET METHOD("CB")
		
		$options:=New object:C1471
		$options.port:=8000  //port<1023 permission may be denied
		$options.host:="127.0.0.1"
		$options.maxConnections:=10
		$options.tls:=True:C214
		$options.caFile:="NONE"  //otherwise, unknown ca
		
		//must be path, not PEM text
		
		$options.certFile:=Folder:C1567(Get 4D folder:C485(Current resources folder:K5:16); fk platform path:K87:2).file("cert.pem").path
		$options.keyFile:=Folder:C1567(Get 4D folder:C485(Current resources folder:K5:16); fk platform path:K87:2).file("key.pem").path
		
		Form:C1466.server:=Websocket server($options)
		
		$status:=Websocket server start(Form:C1466.server)
		
	: ($event.code=On Unload:K2:2)
		
		$status:=Websocket server clear(Form:C1466.server)
		
End case 