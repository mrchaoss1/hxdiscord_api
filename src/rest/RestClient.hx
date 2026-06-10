package rest;

import haxe.Json;
import platform.IHttpClient;

typedef RestCallback = (err:Null<String>, data:Null<Dynamic>) -> Void;

class RestClient {
	static inline final BASE_URL = "https://discord.com/api/v10";
	static inline final USER_AGENT = "DiscordBot (hxdiscord_api, 0.1.0)";

	final http:IHttpClient;
	final token:String;

	public function new(token:String, http:IHttpClient) {
		this.token = token;
		this.http = http;
	}

	public function request(method:String, path:String, ?body:Dynamic, ?cb:RestCallback):Void {
		final headers = [
			"Authorization" => 'Bot $token',
			"User-Agent" => USER_AGENT
		];

		var bodyStr:Null<String> = null;
		if (body != null) {
			headers["Content-Type"] = "application/json";
			bodyStr = Json.stringify(body);
		}

		http.request({
			method: method,
			url: BASE_URL + path,
			headers: headers,
			body: bodyStr
		}, (err, res) -> {
			if (cb == null)
				return;

			if (err != null) {
				cb(err, null);
				return;
			}

			final text = res.body.toString();
			var data:Null<Dynamic> = null;
			if (text.length > 0) {
				try
					data = Json.parse(text)
				catch (_:Dynamic)
					data = null;
			}

			if (res.status >= 400)
				cb('HTTP ${res.status}: $text', data);
			else
				cb(null, data);
		});
	}

	public function get(path:String, ?cb:RestCallback):Void {
		request("GET", path, null, cb);
	}

	public function post(path:String, ?body:Dynamic, ?cb:RestCallback):Void {
		request("POST", path, body, cb);
	}

	public function patch(path:String, ?body:Dynamic, ?cb:RestCallback):Void {
		request("PATCH", path, body, cb);
	}

	public function delete(path:String, ?cb:RestCallback):Void {
		request("DELETE", path, null, cb);
	}

	public function createMessage(channelId:String, params:Dynamic, ?cb:RestCallback):Void {
		post('/channels/$channelId/messages', params, cb);
	}

	public function editMessage(channelId:String, messageId:String, params:Dynamic, ?cb:RestCallback):Void {
		patch('/channels/$channelId/messages/$messageId', params, cb);
	}

	public function deleteMessage(channelId:String, messageId:String, ?cb:RestCallback):Void {
		delete('/channels/$channelId/messages/$messageId', cb);
	}

	public function bulkOverwriteGuildCommands(applicationId:String, guildId:String, commands:Array<Dynamic>, ?cb:RestCallback):Void {
		request("PUT", '/applications/$applicationId/guilds/$guildId/commands', commands, cb);
	}

	public function bulkOverwriteGlobalCommands(applicationId:String, commands:Array<Dynamic>, ?cb:RestCallback):Void {
		request("PUT", '/applications/$applicationId/commands', commands, cb);
	}

	public function createInteractionResponse(interactionId:String, token:String, response:Dynamic, ?cb:RestCallback):Void {
		post('/interactions/$interactionId/$token/callback', response, cb);
	}
}
