package gateway;

enum abstract Opcode(Int) from Int to Int {
	var DISPATCH = 0;
	var HEARTBEAT = 1;
	var IDENTIFY = 2;
	var PRESENCE_UPDATE = 3;
	var VOICE_STATE_UPDATE = 4;
	var RESUME = 6;
	var RECONNECT = 7;
	var REQUEST_GUILD_MEMBERS = 8;
	var INVALID_SESSION = 9;
	var HELLO = 10;
	var HEARTBEAT_ACK = 11;
}
