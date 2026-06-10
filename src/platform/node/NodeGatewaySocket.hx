#if js
package platform.node;

import haxe.io.Bytes;
import js.node.Buffer;
import platform.IGatewaySocket;
import platform.node.extern.WebSocket;

class NodeGatewaySocket implements IGatewaySocket {
	var ws:Null<WebSocket>;

	public function new() {}

	public dynamic function onOpen():Void {}

	public dynamic function onText(data:String):Void {}

	public dynamic function onBinary(data:Bytes):Void {}

	public dynamic function onClose(code:Int, reason:String):Void {}

	public dynamic function onError(message:String):Void {}

	public function connect(url:String):Void {
		final sock = new WebSocket(url);
		ws = sock;

		sock.on("open", () -> onOpen());

		sock.on("message", (data:Buffer, isBinary:Bool) -> {
			if (isBinary)
				onBinary(data.hxToBytes());
			else
				onText(data.toString("utf8"));
		});

		sock.on("close", (code:Int, reason:Buffer) -> {
			onClose(code, reason == null ? "" : reason.toString("utf8"));
		});

		sock.on("error", (err:js.lib.Error) -> {
			onError(err != null && err.message != null ? err.message : "unknown websocket error");
		});
	}

	public function sendText(data:String):Void {
		if (ws != null)
			ws.send(data);
	}

	public function close(?code:Int, ?reason:String):Void {
		if (ws != null)
			ws.close(code, reason);
	}
}
#end
