package commands;

import types.Message;

typedef Condition = Message -> Bool;

class Conditions {
	public static function equals(text:String):Condition {
		return (m) -> m.content == text;
	}

	public static function contains(text:String):Condition {
		return (m) -> m.content != null && m.content.indexOf(text) != -1;
	}

	public static function startsWith(prefix:String):Condition {
		return (m) -> m.content != null && StringTools.startsWith(m.content, prefix);
	}

	public static function endsWith(suffix:String):Condition {
		return (m) -> m.content != null && StringTools.endsWith(m.content, suffix);
	}

	public static function matches(pattern:EReg):Condition {
		return (m) -> m.content != null && pattern.match(m.content);
	}

	public static function fromUser(userId:String):Condition {
		return (m) -> (m.author.id : String) == userId;
	}

	public static function inChannel(channelId:String):Condition {
		return (m) -> (m.channel_id : String) == channelId;
	}

	public static function all(conditions:Array<Condition>):Condition {
		return (m) -> {
			for (c in conditions)
				if (!c(m))
					return false;
			return true;
		};
	}

	public static function any(conditions:Array<Condition>):Condition {
		return (m) -> {
			for (c in conditions)
				if (c(m))
					return true;
			return false;
		};
	}

	public static function not(condition:Condition):Condition {
		return (m) -> !condition(m);
	}
}
