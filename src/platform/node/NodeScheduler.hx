#if js
package platform.node;

import js.node.Timers;
import js.node.Timers.Timeout;
import platform.IScheduler;

class NodeScheduler implements IScheduler {
	public function new() {}

	public function setTimeout(ms:Int, fn:() -> Void):TimerHandle {
		return new NodeTimerHandle(Timers.setTimeout(fn, ms), false);
	}

	public function setInterval(ms:Int, fn:() -> Void):TimerHandle {
		return new NodeTimerHandle(Timers.setInterval(fn, ms), true);
	}

	public function clear(handle:TimerHandle):Void {
		final h:NodeTimerHandle = handle;
		if (h == null || h.timeout == null)
			return;
		if (h.repeating)
			Timers.clearInterval(h.timeout);
		else
			Timers.clearTimeout(h.timeout);
	}
}

private class NodeTimerHandle {
	public final timeout:Timeout;
	public final repeating:Bool;

	public function new(timeout:Timeout, repeating:Bool) {
		this.timeout = timeout;
		this.repeating = repeating;
	}
}
#end
