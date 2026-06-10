#if sys
package platform.sys;

import haxe.io.Bytes;
import haxe.net.WebSocket;
import platform.IGatewaySocket;

class SysGatewaySocket implements IGatewaySocket {
	static inline final POLL_INTERVAL_MS = 10;

	var ws:Null<WebSocket>;
	var pump:Null<haxe.Timer>;

	public function new() {}

	public dynamic function onOpen():Void {}

	public dynamic function onText(data:String):Void {}

	public dynamic function onBinary(data:Bytes):Void {}

	public dynamic function onClose(code:Int, reason:String):Void {}

	public dynamic function onError(message:String):Void {}

	public function connect(url:String):Void {
		final sock = WebSocket.create(url);
		ws = sock;

		sock.onopen = () -> onOpen();
		sock.onmessageString = (message) -> onText(message);
		sock.onmessageBytes = (message) -> onBinary(message);
		sock.onclose = () -> onClose(0, "");
		sock.onerror = (message) -> onError(message);

		final timer = new haxe.Timer(POLL_INTERVAL_MS);
		timer.run = () -> sock.process();
		pump = timer;
	}

	public function sendText(data:String):Void {
		if (ws != null)
			ws.sendString(data);
	}

	public function close(?code:Int, ?reason:String):Void {
		if (pump != null) {
			pump.stop();
			pump = null;
		}
		if (ws != null)
			ws.close();
	}
}
#end
