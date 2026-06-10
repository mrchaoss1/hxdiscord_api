package platform;

class Platform {
	public static function http():IHttpClient {
		#if js
		return new platform.node.NodeHttpClient();
		#elseif sys
		return new platform.sys.SysHttpClient();
		#else
		throw "hxdiscord_api: no platform implementation for this target";
		#end
	}

	public static function socket():IGatewaySocket {
		#if js
		return new platform.node.NodeGatewaySocket();
		#elseif sys
		return new platform.sys.SysGatewaySocket();
		#else
		throw "hxdiscord_api: no platform implementation for this target";
		#end
	}

	public static function scheduler():IScheduler {
		#if js
		return new platform.node.NodeScheduler();
		#elseif sys
		return new platform.sys.SysScheduler();
		#else
		throw "hxdiscord_api: no platform implementation for this target";
		#end
	}
}
