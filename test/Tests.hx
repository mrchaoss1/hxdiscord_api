package;

import types.Snowflake;
import types.Message;
import gateway.Intents;
import commands.Conditions;

class Tests {
	static var passed = 0;
	static var failed = 0;

	static function check(name:String, condition:Bool):Void {
		if (condition) {
			passed++;
			Sys.println('  ok    $name');
		} else {
			failed++;
			Sys.println('  FAIL  $name');
		}
	}

	static function fakeMessage(content:String, ?authorId:String = "1", ?channelId:String = "100"):Message {
		return cast {
			content: content,
			channel_id: channelId,
			author: {id: authorId, username: "user", discriminator: "0", bot: false}
		};
	}

	static function main() {
		Sys.println("== hxdiscord_api tests ==");

		testSnowflake();
		testIntents();
		testConditions();

		Sys.println("");
		Sys.println(failed == 0 ? 'ALL ${passed} TESTS PASSED' : '${failed} FAILED, ${passed} PASSED');
		Sys.exit(failed == 0 ? 0 : 1);
	}

	static function testSnowflake():Void {
		final id:Snowflake = "175928847299117063";
		check("snowflake decodes timestamp", Math.abs(id.timestampMs() - 1462015105796.0) < 1.0);
		check("snowflake isValid accepts digits", id.isValid());
		check("snowflake isValid rejects letters", !(("12ab" : Snowflake).isValid()));
		check("snowflake equality", ("42" : Snowflake) == ("42" : Snowflake));
	}

	static function testIntents():Void {
		final i = Intents.GUILDS | Intents.GUILD_MESSAGES | Intents.MESSAGE_CONTENT;
		check("intents has GUILDS", i.has(Intents.GUILDS));
		check("intents has MESSAGE_CONTENT", i.has(Intents.MESSAGE_CONTENT));
		check("intents lacks GUILD_PRESENCES", !i.has(Intents.GUILD_PRESENCES));
	}

	static function testConditions():Void {
		check("contains matches", Conditions.contains("ping")(fakeMessage("!ping")));
		check("contains misses", !Conditions.contains("pong")(fakeMessage("!ping")));
		check("equals matches", Conditions.equals("hello")(fakeMessage("hello")));
		check("startsWith matches", Conditions.startsWith("!")(fakeMessage("!cmd")));
		check("endsWith matches", Conditions.endsWith("!")(fakeMessage("hi!")));
		check("matches regex", Conditions.matches(~/\bbye\b/i)(fakeMessage("ok BYE now")));
		check("fromUser matches", Conditions.fromUser("42")(fakeMessage("x", "42")));
		check("fromUser misses", !Conditions.fromUser("42")(fakeMessage("x", "7")));
		check("inChannel matches", Conditions.inChannel("100")(fakeMessage("x")));

		final hasBoth = Conditions.all([Conditions.contains("a"), Conditions.contains("b")]);
		check("all true", hasBoth(fakeMessage("a b")));
		check("all false", !hasBoth(fakeMessage("a only")));

		final hasEither = Conditions.any([Conditions.contains("x"), Conditions.contains("b")]);
		check("any true", hasEither(fakeMessage("b")));
		check("any false", !hasEither(fakeMessage("none")));

		check("not inverts", Conditions.not(Conditions.contains("z"))(fakeMessage("abc")));
	}
}
