package types;

abstract Snowflake(String) from String to String {
	public static inline final DISCORD_EPOCH:Float = 1420070400000.0;

	public inline function new(value:String) {
		this = value;
	}

	public inline function toString():String {
		return this;
	}

	public function timestampMs():Float {
		final id = Std.parseFloat(this);
		return Math.ffloor(id / 4194304.0) + DISCORD_EPOCH;
	}

	public inline function timestamp():Date {
		return Date.fromTime(timestampMs());
	}

	public function isValid():Bool {
		if (this == null || this.length == 0)
			return false;
		for (i in 0...this.length) {
			final c = this.charCodeAt(i);
			if (c < '0'.code || c > '9'.code)
				return false;
		}
		return true;
	}

	@:op(A == B) static inline function eq(a:Snowflake, b:Snowflake):Bool {
		return (a : String) == (b : String);
	}

	@:op(A != B) static inline function neq(a:Snowflake, b:Snowflake):Bool {
		return (a : String) != (b : String);
	}
}
