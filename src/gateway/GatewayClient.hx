package gateway;

import haxe.Json;
import gateway.Opcodes.Opcode;
import platform.IGatewaySocket;
import platform.IScheduler;
import platform.IScheduler.TimerHandle;

class GatewayClient {
	static inline final GATEWAY_URL = "wss://gateway.discord.gg/?v=10&encoding=json";

	final socket:IGatewaySocket;
	final scheduler:IScheduler;
	final token:String;
	final intents:Int;

	var heartbeatInterval:Int = 0;
	var heartbeatTimeout:Null<TimerHandle> = null;
	var heartbeatInterval2:Null<TimerHandle> = null;
	var lastSeq:Null<Int> = null;
	var awaitingAck:Bool = false;

	public var sessionId:Null<String> = null;
	public var resumeGatewayUrl:Null<String> = null;

	public dynamic function onReady(data:Dynamic):Void {}

	public dynamic function onDispatch(type:String, data:Dynamic):Void {}

	public dynamic function onLog(message:String):Void {}

	public function new(token:String, intents:Int, socket:IGatewaySocket, scheduler:IScheduler) {
		this.token = token;
		this.intents = intents;
		this.socket = socket;
		this.scheduler = scheduler;
	}

	public function connect():Void {
		socket.onOpen = () -> log("socket open");
		socket.onText = handleText;
		socket.onBinary = (_) -> {};
		socket.onClose = (code, reason) -> {
			stopHeartbeat();
			log('socket closed: $code ${reason == "" ? "" : '($reason)'}');
		};
		socket.onError = (m) -> log('socket error: $m');
		socket.connect(GATEWAY_URL);
	}

	public function close(?code:Int, ?reason:String):Void {
		stopHeartbeat();
		socket.close(code, reason);
	}

	function handleText(raw:String):Void {
		final payload:Dynamic = Json.parse(raw);
		final op:Opcode = payload.op;

		if (payload.s != null)
			lastSeq = payload.s;

		switch (op) {
			case HELLO:
				heartbeatInterval = payload.d.heartbeat_interval;
				log('hello (heartbeat every ${heartbeatInterval}ms)');
				startHeartbeat();
				identify();

			case HEARTBEAT_ACK:
				awaitingAck = false;

			case HEARTBEAT:
				sendHeartbeat();

			case DISPATCH:
				final type:String = payload.t;
				if (type == "READY") {
					sessionId = payload.d.session_id;
					resumeGatewayUrl = payload.d.resume_gateway_url;
					onReady(payload.d);
				}
				onDispatch(type, payload.d);

			case RECONNECT:
				log("server requested reconnect");

			case INVALID_SESSION:
				log("invalid session");

			default:
				log('unhandled opcode ${(op : Int)}');
		}
	}

	function identify():Void {
		send({
			op: Opcode.IDENTIFY,
			d: {
				token: token,
				intents: intents,
				properties: {
					os: "linux",
					browser: "hxdiscord_api",
					device: "hxdiscord_api"
				}
			}
		});
	}

	function startHeartbeat():Void {
		stopHeartbeat();
		final firstDelay = Std.int(heartbeatInterval * Math.random());
		heartbeatTimeout = scheduler.setTimeout(firstDelay, () -> {
			sendHeartbeat();
			heartbeatInterval2 = scheduler.setInterval(heartbeatInterval, () -> {
				if (awaitingAck) {
					log("heartbeat not acked, connection is zombied");
					close(4000, "heartbeat timeout");
					return;
				}
				sendHeartbeat();
			});
		});
	}

	function stopHeartbeat():Void {
		if (heartbeatTimeout != null) {
			scheduler.clear(heartbeatTimeout);
			heartbeatTimeout = null;
		}
		if (heartbeatInterval2 != null) {
			scheduler.clear(heartbeatInterval2);
			heartbeatInterval2 = null;
		}
	}

	function sendHeartbeat():Void {
		awaitingAck = true;
		send({op: Opcode.HEARTBEAT, d: lastSeq});
	}

	function send(payload:Dynamic):Void {
		socket.sendText(Json.stringify(payload));
	}

	inline function log(message:String):Void {
		onLog(message);
	}
}
