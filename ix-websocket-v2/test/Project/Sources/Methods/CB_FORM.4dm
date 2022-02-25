//%attributes = {"invisible":true}
#DECLARE($type : Integer; $socket : Integer; $message : Text)

Case of 
	: (Count parameters:C259=0)
		
		WINDOW LIST:C442($_windows; *)
		$windows:=New collection:C1472
		
		ARRAY TO COLLECTION:C1563($windows; $_windows)
		
		$found:=False:C215
		
		For each ($window; $windows) Until ($found)
			$found:=(Get window title:C450($window)="TEST")
		End for each 
		
		Use (Storage:C1525)
			If ($found)
				Storage:C1525.CB:=New shared object:C1526("window"; $window)
				GET WINDOW RECT:C443($x; $y; $right; $bottom; $window)
				SET WINDOW RECT:C444($x; $y; $right; $bottom; $window)
			Else 
				$window:=Open form window:C675("SERVER")
				SET WINDOW TITLE:C213("INFO"; $window)
				Storage:C1525.CB:=New shared object:C1526("window"; $window)
				DIALOG:C40("SERVER"; *)
			End if 
		End use 
		
	: (Count parameters:C259=3)
		
		$line:=New object:C1471("socket"; $socket)
		
		$line.message:=JSON Parse:C1218($message)
		
		Case of 
			: ($type=0)
				$line.type:="Message"
			: ($type=1)
				$line.type:="Open"
			: ($type=2)
				$line.type:="Close"
			: ($type=3)
				$line.type:="Error"
		End case 
		
		Form:C1466.CB.col.unshift($line)
		Form:C1466.CB.item:=Null:C1517
		
		If ($socket<0)  //server socket is negative 
			If ($line.type="Message")
				
				$uri:=$line.message.uri
				
				$col:=Split string:C1554($uri; "=")
				If ($col.length>1)
					$server:=New object:C1471("id"; $socket; "message"; "Hello "+$col[1]; "uri"; $uri)
					$status:=Websocket server send($server)
				End if 
				
			End if 
			
		End if 
		
End case 