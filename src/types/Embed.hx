package types;

typedef Embed = {
	var ?title:String;
	var ?type:String;
	var ?description:String;
	var ?url:String;
	var ?timestamp:String;
	var ?color:Int;
	var ?footer:EmbedFooter;
	var ?image:EmbedMedia;
	var ?thumbnail:EmbedMedia;
	var ?video:EmbedMedia;
	var ?provider:EmbedProvider;
	var ?author:EmbedAuthor;
	var ?fields:Array<EmbedField>;
}

typedef EmbedFooter = {
	var text:String;
	var ?icon_url:String;
	var ?proxy_icon_url:String;
}

typedef EmbedMedia = {
	var ?url:String;
	var ?proxy_url:String;
	var ?height:Int;
	var ?width:Int;
}

typedef EmbedProvider = {
	var ?name:String;
	var ?url:String;
}

typedef EmbedAuthor = {
	var name:String;
	var ?url:String;
	var ?icon_url:String;
	var ?proxy_icon_url:String;
}

typedef EmbedField = {
	var name:String;
	var value:String;
}

class EmbedFieldTools {
	public static inline function getInline(field:EmbedField):Bool {
		return Reflect.field(field, "inline") == true;
	}

	public static inline function setInline(field:EmbedField, value:Bool):Void {
		Reflect.setField(field, "inline", value);
	}
}
