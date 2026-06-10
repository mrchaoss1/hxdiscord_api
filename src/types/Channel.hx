package types;

typedef Channel = {
	var id:Snowflake;
	var type:ChannelType;
	var ?guild_id:Snowflake;
	var ?position:Int;
	var ?permission_overwrites:Array<Overwrite>;
	var ?name:Null<String>;
	var ?topic:Null<String>;
	var ?nsfw:Bool;
	var ?last_message_id:Null<Snowflake>;
	var ?bitrate:Int;
	var ?user_limit:Int;
	var ?rate_limit_per_user:Int;
	var ?recipients:Array<User>;
	var ?parent_id:Null<Snowflake>;
	var ?owner_id:Snowflake;
	var ?permissions:String;
}

typedef Overwrite = {
	var id:Snowflake;
	var type:Int;
	var allow:String;
	var deny:String;
}
