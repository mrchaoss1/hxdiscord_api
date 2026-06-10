package types;

typedef Emoji = {
	var id:Null<Snowflake>;
	var name:Null<String>;
	var ?roles:Array<Snowflake>;
	var ?user:User;
	var ?require_colons:Bool;
	var ?managed:Bool;
	var ?animated:Bool;
	var ?available:Bool;
}
