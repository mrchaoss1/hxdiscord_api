package commands;

import types.User;
import types.Message;
import types.interactions.Interaction;
import commands.ReplyStyle;
import rest.RestClient.RestCallback;

class Context {
	static inline final RESPONSE_CHANNEL_MESSAGE = 4;
	static inline final FLAG_EPHEMERAL = 64;

	public final client:Client;
	public final message:Null<Message>;
	public final interaction:Null<Interaction>;
	public final args:Array<String>;

	public var user(get, never):Null<User>;
	public var argString(get, never):String;

	public function new(client:Client, message:Null<Message>, interaction:Null<Interaction>, ?args:Array<String>) {
		this.client = client;
		this.message = message;
		this.interaction = interaction;
		this.args = args == null ? [] : args;
	}

	public function reply(content:String, ?style:ReplyStyle, ?cb:RestCallback):Void {
		if (interaction != null) {
			final data:Dynamic = {content: content};
			if (style == Ephemeral)
				data.flags = FLAG_EPHEMERAL;

			client.rest.createInteractionResponse(interaction.id, interaction.token, {
				type: RESPONSE_CHANNEL_MESSAGE,
				data: data
			}, cb);
		} else if (message != null) {
			if (style == Reply)
				client.reply(message, content, cb);
			else
				client.sendMessage(message.channel_id, content, cb);
		}
	}

	function get_user():Null<User> {
		if (interaction != null) {
			if (interaction.member != null && interaction.member.user != null)
				return interaction.member.user;
			return interaction.user;
		}
		if (message != null)
			return message.author;
		return null;
	}

	function get_argString():String {
		return args.join(" ");
	}
}
