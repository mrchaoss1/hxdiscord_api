package;

import types.User;
import types.Embed;
import types.Message;
import types.Snowflake;
import types.interactions.Interaction;
import rest.RestClient;
import rest.RestClient.RestCallback;
import gateway.GatewayClient;
import commands.Context;
import commands.Command;
import commands.Conditions.Condition;
import platform.Platform;

typedef MessageRule = {
	var condition:Condition;
	var handler:Context -> Void;
}

typedef PrefixCommand = {
	var prefix:Null<String>;
	var name:String;
	var handler:Context -> Void;
}

class Client {
	public final rest:RestClient;

	public var user:Null<User> = null;
	public var applicationId:Null<Snowflake> = null;

	public var commandPrefix:String = "!";

	final gateway:GatewayClient;
	final prefixCommands:Array<PrefixCommand> = [];
	final messageRules:Array<MessageRule> = [];
	final slashDefinitions:Array<Dynamic> = [];
	final slashHandlers = new Map<String, Context -> Void>();
	final registeredGuilds = new Map<String, Bool>();

	public dynamic function onReady():Void {}

	public dynamic function onMessageCreate(message:Message):Void {}

	public dynamic function onDispatch(type:String, data:Dynamic):Void {}

	public dynamic function onLog(message:String):Void {}

	public function new(token:String, intents:Int) {
		rest = new RestClient(token, Platform.http());
		gateway = new GatewayClient(token, intents, Platform.socket(), Platform.scheduler());

		gateway.onLog = (m) -> onLog(m);
		gateway.onReady = (data) -> {
			user = data.user;
			if (data.application != null)
				applicationId = data.application.id;
			onReady();
		};
		gateway.onDispatch = (type, data) -> handleDispatch(type, data);
	}

	public function connect():Void {
		gateway.connect();
	}

	public function close(?code:Int, ?reason:String):Void {
		gateway.close(code, reason);
	}

	public function sendMessage(channelId:String, content:String, ?cb:RestCallback):Void {
		rest.createMessage(channelId, {content: content}, cb);
	}

	public function sendEmbed(channelId:String, embed:Embed, ?cb:RestCallback):Void {
		rest.createMessage(channelId, {embeds: [embed]}, cb);
	}

	public function reply(message:Message, content:String, ?cb:RestCallback):Void {
		rest.createMessage(message.channel_id, {
			content: content,
			message_reference: {message_id: message.id}
		}, cb);
	}

	public function add(command:haxe.extern.EitherType<String, Command>, ?execute:Context -> Void, ?prefix:String):Client {
		if (Std.isOfType(command, String))
			register({name: (command : String), execute: execute, prefix: prefix});
		else
			register((command : Command));
		return this;
	}

	function register(command:Command):Void {
		if (command.when != null) {
			messageRules.push({condition: command.when, handler: command.execute});
		} else if (command.description != null) {
			final def:Dynamic = {name: command.name, description: command.description, type: 1};
			if (command.options != null)
				def.options = command.options;

			slashDefinitions.push(def);
			slashHandlers.set(command.name, command.execute);
		} else if (command.name != null) {
			prefixCommands.push({
				prefix: command.prefix,
				name: command.name.toLowerCase(),
				handler: command.execute
			});
		}
	}

	function handleDispatch(type:String, data:Dynamic):Void {
		switch (type) {
			case "MESSAGE_CREATE":
				final message:Message = data;
				onMessageCreate(message);
				runPrefixCommand(message);
				runRules(message);
			case "GUILD_CREATE":
				registerGuildCommands(data.id);
			case "INTERACTION_CREATE":
				handleInteraction(data);
			default:
		}
		onDispatch(type, data);
	}

	function runRules(message:Message):Void {
		if (message.author.bot == true)
			return;

		for (rule in messageRules) {
			if (rule.condition(message))
				rule.handler(new Context(this, message, null));
		}
	}

	function runPrefixCommand(message:Message):Void {
		if (message.author.bot == true)
			return;

		final content = message.content;
		if (content == null)
			return;

		for (cmd in prefixCommands) {
			final prefix = cmd.prefix != null ? cmd.prefix : commandPrefix;
			final head = prefix + cmd.name;

			if (content.length < head.length)
				continue;
			if (content.substr(0, head.length).toLowerCase() != head.toLowerCase())
				continue;

			if (content.length > head.length) {
				final next = content.charAt(head.length);
				if (next != " " && next != "\t" && next != "\n" && next != "\r")
					continue;
			}

			final rest = StringTools.trim(content.substr(head.length));
			final args = rest.length == 0 ? [] : (~/\s+/g).split(rest);
			cmd.handler(new Context(this, message, null, args));
			return;
		}
	}

	function registerGuildCommands(guildId:String):Void {
		if (slashDefinitions.length == 0 || applicationId == null)
			return;
		if (registeredGuilds.exists(guildId))
			return;
		registeredGuilds.set(guildId, true);

		rest.bulkOverwriteGuildCommands(applicationId, guildId, slashDefinitions, (err, _) -> {
			if (err != null)
				onLog('failed to register slash commands in guild $guildId: $err');
			else
				onLog('registered ${slashDefinitions.length} slash command(s) in guild $guildId');
		});
	}

	function handleInteraction(interaction:Interaction):Void {
		if (interaction.type != 2 || interaction.data == null)
			return;

		final handler = slashHandlers.get(interaction.data.name);
		if (handler == null)
			return;

		handler(new Context(this, null, interaction));
	}
}
