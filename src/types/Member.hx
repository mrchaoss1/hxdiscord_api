package types;

typedef Member = {
	var ?user:User;
	var ?nick:Null<String>;
	var ?avatar:Null<String>;
	var roles:Array<Snowflake>;
	var joined_at:String;
	var ?premium_since:Null<String>;
	var ?deaf:Bool;
	var ?mute:Bool;
	var ?flags:Int;
	var ?pending:Bool;
	var ?permissions:String;
	var ?communication_disabled_until:Null<String>;
}
