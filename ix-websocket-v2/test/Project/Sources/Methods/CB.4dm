//%attributes = {"invisible":true}
#DECLARE($type : Integer; $socket : Integer; $message : Text)

If (Storage:C1525.CB#Null:C1517)
	CALL FORM:C1391(Storage:C1525.CB.window; "CB_FORM"; $type; $socket; $message)
End if 