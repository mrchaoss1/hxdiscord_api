package types;

typedef Message = {
	var id:Snowflake;
	var channel_id:Snowflake;
	var ?guild_id:Snowflake;
	var author:User;
	var ?member:Member;
	var content:String;
	var timestamp:String;
	var ?edited_timestamp:Null<String>;
	var tts:Bool;
	var mention_everyone:Bool;
	var mentions:Array<User>;
	var mention_roles:Array<Snowflake>;
	var attachments:Array<Attachment>;
	var embeds:Array<Embed>;
	var ?reactions:Array<Reaction>;
	var pinned:Bool;
	var ?webhook_id:Snowflake;
	var type:MessageType;
	var ?referenced_message:Null<Message>;
	var ?components:Array<Dynamic>;
}
