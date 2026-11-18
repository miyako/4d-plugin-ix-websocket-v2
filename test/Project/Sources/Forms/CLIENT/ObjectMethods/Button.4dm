If (Form event code:C388=On Clicked:K2:4)
	
	Form:C1466.client.message:=Form:C1466.message
	
	$status:=Websocket client send(Form:C1466.client)
	
End if 