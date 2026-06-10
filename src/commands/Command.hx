package commands;

import commands.Conditions.Condition;

typedef Command = {
	var ?name:String;
	var ?prefix:String;
	var ?description:String;
	var ?when:Condition;
	var ?options:Array<Dynamic>;
	var execute:Context -> Void;
}
