#if sys
package platform.sys;

import haxe.Timer;
import platform.IScheduler;

class SysScheduler implements IScheduler {
	public function new() {}

	public function setTimeout(ms:Int, fn:() -> Void):TimerHandle {
		return Timer.delay(fn, ms);
	}

	public function setInterval(ms:Int, fn:() -> Void):TimerHandle {
		final timer = new Timer(ms);
		timer.run = fn;
		return timer;
	}

	public function clear(handle:TimerHandle):Void {
		final timer:Timer = handle;
		if (timer != null)
			timer.stop();
	}
}
#end
