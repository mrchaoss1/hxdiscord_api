package platform;

typedef TimerHandle = Dynamic;

interface IScheduler {
	function setTimeout(ms:Int, fn:() -> Void):TimerHandle;
	function setInterval(ms:Int, fn:() -> Void):TimerHandle;
	function clear(handle:TimerHandle):Void;
}
