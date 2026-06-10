package types;

typedef User = {
	var id:Snowflake;
	var username:String;
	var discriminator:String;
	var ?global_name:Null<String>;
	var ?avatar:Null<String>;
	var ?bot:Bool;
	var ?system:Bool;
	var ?mfa_enabled:Bool;
	var ?banner:Null<String>;
	var ?accent_color:Null<Int>;
	var ?locale:String;
	var ?flags:Int;
	var ?premium_type:Int;
	var ?public_flags:Int;
}
