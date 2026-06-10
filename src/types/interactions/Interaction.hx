package types.interactions;

import types.User;
import types.Member;
import types.Snowflake;

typedef Interaction = {
	var id:Snowflake;
	var application_id:Snowflake;
	var type:Int;
	var ?data:InteractionData;
	var ?guild_id:Snowflake;
	var ?channel_id:Snowflake;
	var ?member:Member;
	var ?user:User;
	var token:String;
	var version:Int;
}

typedef InteractionData = {
	var id:Snowflake;
	var name:String;
	var type:Int;
	var ?options:Array<InteractionOption>;
}

typedef InteractionOption = {
	var name:String;
	var type:Int;
	var ?value:Dynamic;
	var ?options:Array<InteractionOption>;
}
