package types;

typedef Role = {
	var id:Snowflake;
	var name:String;
	var color:Int;
	var hoist:Bool;
	var ?icon:Null<String>;
	var ?unicode_emoji:Null<String>;
	var position:Int;
	var permissions:String;
	var managed:Bool;
	var mentionable:Bool;
	var ?flags:Int;
}
