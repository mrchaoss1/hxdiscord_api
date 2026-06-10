package types;

typedef Attachment = {
	var id:Snowflake;
	var filename:String;
	var ?content_type:String;
	var size:Int;
	var url:String;
	var proxy_url:String;
	var ?height:Null<Int>;
	var ?width:Null<Int>;
	var ?description:String;
	var ?ephemeral:Bool;
}
