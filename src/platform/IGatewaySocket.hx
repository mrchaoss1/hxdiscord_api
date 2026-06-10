package platform;

import haxe.io.Bytes;

interface IGatewaySocket {
	dynamic function onOpen():Void;
	dynamic function onText(data:String):Void;
	dynamic function onBinary(data:Bytes):Void;
	dynamic function onClose(code:Int, reason:String):Void;
	dynamic function onError(message:String):Void;

	function connect(url:String):Void;
	function sendText(data:String):Void;
	function close(?code:Int, ?reason:String):Void;
}
