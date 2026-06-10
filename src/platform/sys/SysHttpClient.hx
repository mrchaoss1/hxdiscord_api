#if sys
package platform.sys;

import haxe.io.Bytes;
import haxe.io.BytesOutput;
import platform.IHttpClient;

class SysHttpClient implements IHttpClient {
	public function new() {}

	public function request(req:HttpRequest, cb:(err:Null<String>, res:Null<HttpResponse>) -> Void):Void {
		final http = new haxe.Http(req.url);

		if (req.headers != null) {
			for (k in req.headers.keys())
				http.setHeader(k, req.headers.get(k));
		}

		if (req.body != null) {
			if (Std.isOfType(req.body, String))
				http.setPostData((cast req.body : String));
			else
				http.setPostBytes((cast req.body : Bytes));
		}

		var status = 0;
		http.onStatus = (s) -> status = s;

		var error:Null<String> = null;
		http.onError = (e) -> error = e;

		final out = new BytesOutput();
		final isPost = req.method != "GET";

		try {
			http.customRequest(isPost, out, null, req.method);
		} catch (e:Dynamic) {
			cb(Std.string(e), null);
			return;
		}

		if (error != null) {
			cb(error, null);
			return;
		}

		final headers = new Map<String, String>();
		if (http.responseHeaders != null) {
			for (k in http.responseHeaders.keys())
				headers.set(k.toLowerCase(), http.responseHeaders.get(k));
		}

		cb(null, {status: status, headers: headers, body: out.getBytes()});
	}
}
#end
