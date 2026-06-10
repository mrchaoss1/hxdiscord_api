package types;

typedef Guild = {
	var id:Snowflake;
	var name:String;
	var ?icon:Null<String>;
	var ?splash:Null<String>;
	var owner_id:Snowflake;
	var ?owner:Bool;
	var ?afk_channel_id:Null<Snowflake>;
	var ?afk_timeout:Int;
	var ?verification_level:Int;
	var roles:Array<Role>;
	var emojis:Array<Emoji>;
	var features:Array<String>;
	var ?preferred_locale:String;
	var ?joined_at:String;
	var ?large:Bool;
	var ?unavailable:Bool;
	var ?member_count:Int;
	var ?members:Array<Member>;
	var ?channels:Array<Channel>;
}
