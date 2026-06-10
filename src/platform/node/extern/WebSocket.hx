#if js
package platform.node.extern;

import haxe.Constraints.Function;

@:jsRequire("ws")
extern class WebSocket {
	function new(address:String, ?protocols:Dynamic, ?options:Dynamic);

	var readyState(default, null):Int;

	static var CONNECTING:Int;
	static var OPEN:Int;
	static var CLOSING:Int;
	static var CLOSED:Int;

	@:overload(function(data:js.node.Buffer, ?cb:Dynamic -> Void):Void {})
	function send(data:String, ?cb:Dynamic -> Void):Void;

	function close(?code:Int, ?reason:String):Void;
	function terminate():Void;

	function on(event:String, listener:Function):WebSocket;
}
#end
