//%attributes = {}
#DECLARE($port : Integer)->$status : Object

//$ciphers:=""
//$param:=Get database parameter(SSL cipher list; $ciphers)
//$ciphers:="ALL:!ADH:!RC4:+HIGH:+MEDIUM:-LOW:-SSLv2:-SSLv3:-EXP"

CALL WORKER:C1389(1; Formula:C1597(CB_FORM).source)
