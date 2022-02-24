//%attributes = {}
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
				$window:=Open form window:C675("CB")
				SET WINDOW TITLE:C213("TEST"; $window)
				Storage:C1525.CB:=New shared object:C1526("window"; $window)
				DIALOG:C40("CB"; *)
			End if 
		End use 
		
	: (Count parameters:C259=3)
		
		$line:=New object:C1471("socket"; $socket)
		
		Case of 
			: ($type=0)
				$line.type:="Message"
				$line.message:=$message
			: ($type=1)
				$line.type:="Open"
				$line.message:=JSON Parse:C1218($message)
			: ($type=2)
				$line.type:="Close"
				$line.message:=JSON Parse:C1218($message)
			: ($type=3)
				$line.type:="Error"
				$line.message:=JSON Parse:C1218($message)
		End case 
		
		Form:C1466.CB.col.unshift($line)
		
End case 