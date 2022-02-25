$event:=FORM Event:C1606

Case of 
	: ($event.code=On Load:K2:1)
		
		Form:C1466.window:=String:C10(Current form window:C827)
		
		SET WINDOW TITLE:C213(Form:C1466.window; Current form window:C827)
		
		$options:=New object:C1471
		$options.URL:="wss://127.0.0.1:8000/api?window="+Form:C1466.window
		$options.tls:=True:C214
		$options.caFile:="NONE"  //otherwise, unknown ca
		
		Form:C1466.client:=Websocket client($options)
		
		Form:C1466.client.timeout:=10  //sec
		$status:=Websocket client start(Form:C1466.client)
		
	: ($event.code=On Unload:K2:2)
		
		$status:=Websocket client clear(Form:C1466.client)
		
End case 