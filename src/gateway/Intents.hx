package gateway;

enum abstract Intents(Int) from Int to Int {
	var GUILDS = 1 << 0;
	var GUILD_MEMBERS = 1 << 1;
	var GUILD_MODERATION = 1 << 2;
	var GUILD_EMOJIS_AND_STICKERS = 1 << 3;
	var GUILD_INTEGRATIONS = 1 << 4;
	var GUILD_WEBHOOKS = 1 << 5;
	var GUILD_INVITES = 1 << 6;
	var GUILD_VOICE_STATES = 1 << 7;
	var GUILD_PRESENCES = 1 << 8;
	var GUILD_MESSAGES = 1 << 9;
	var GUILD_MESSAGE_REACTIONS = 1 << 10;
	var GUILD_MESSAGE_TYPING = 1 << 11;
	var DIRECT_MESSAGES = 1 << 12;
	var DIRECT_MESSAGE_REACTIONS = 1 << 13;
	var DIRECT_MESSAGE_TYPING = 1 << 14;
	var MESSAGE_CONTENT = 1 << 15;
	var GUILD_SCHEDULED_EVENTS = 1 << 16;
	var AUTO_MODERATION_CONFIGURATION = 1 << 20;
	var AUTO_MODERATION_EXECUTION = 1 << 21;
	var GUILD_MESSAGE_POLLS = 1 << 24;
	var DIRECT_MESSAGE_POLLS = 1 << 25;

	@:op(A | B) static inline function or(a:Intents, b:Intents):Intents {
		return (a : Int) | (b : Int);
	}

	public inline function has(flag:Intents):Bool {
		return (this & (flag : Int)) != 0;
	}
}
