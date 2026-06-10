package;

// The same code runs on both targets:
//   Node.js:  haxe bot.hxml       && node bin/bot.js
//   C++:      haxe build-cpp.hxml  && ./bin/cpp/Main
// The platform layer is chosen automatically; nothing below changes per target.

import gateway.Intents;
import commands.ReplyStyle;

class Main {
	static function main() {
		final token = "PASTE_YOUR_TOKEN";

		final client = new Client(token, Intents.GUILDS | Intents.GUILD_MESSAGES | Intents.MESSAGE_CONTENT);

		client.onReady = () -> Sys.println('logged in as ${client.user.username}');

		client.add("ping", ctx -> ctx.reply("pong"));
		client.add("hi", ctx -> ctx.reply("hello!", Reply));

		client.add({
			name: "secret",
			description: "A reply only you can see",
			execute: ctx -> ctx.reply("only you can see this", Ephemeral)
		});

		client.connect();
	}
}
