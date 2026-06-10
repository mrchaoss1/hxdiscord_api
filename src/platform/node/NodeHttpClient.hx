#if js
package platform.node;

import haxe.io.Bytes;
import js.node.Buffer;
import js.node.Https;
import js.node.http.IncomingMessage;
import js.node.http.ClientRequest;
import platform.IHttpClient;

class NodeHttpClient implements IHttpClient {
	public function new() {}

	public function request(req:HttpRequest, cb:(err:Null<String>, res:Null<HttpResponse>) -> Void):Void {
		var settled = false;
		inline function done(err:Null<String>, res:Null<HttpResponse>):Void {
			if (settled)
				return;
			settled = true;
			cb(err, res);
		}

		final headers:Dynamic = {};
		if (req.headers != null) {
			for (k in req.headers.keys())
				Reflect.setField(headers, k, req.headers.get(k));
		}

		final options:Dynamic = {method: req.method, headers: headers};

		final clientReq:ClientRequest = untyped Https.request(req.url, options, function(res:IncomingMessage) {
			final chunks:Array<Buffer> = [];
			res.on("data", (chunk:Buffer) -> chunks.push(chunk));
			res.on("end", () -> {
				final bodyBuf = Buffer.concat(chunks);

				final outHeaders = new Map<String, String>();
				final raw:Dynamic = res.headers;
				for (field in Reflect.fields(raw)) {
					final v:Dynamic = Reflect.field(raw, field);
					final value = Std.isOfType(v, Array) ? (cast v : Array<Dynamic>).join(", ") : Std.string(v);
					outHeaders.set(field.toLowerCase(), value);
				}

				done(null, {
					status: res.statusCode,
					headers: outHeaders,
					body: bodyBuf.hxToBytes(),
				});
			});
			res.on("error", (e:js.lib.Error) -> done(errMessage(e), null));
		});

		clientReq.on("error", (e:js.lib.Error) -> done(errMessage(e), null));

		if (req.body != null) {
			if (Std.isOfType(req.body, String))
				clientReq.write((cast req.body : String));
			else
				clientReq.write(Buffer.hxFromBytes((cast req.body : Bytes)));
		}
		clientReq.end();
	}

	static inline function errMessage(e:js.lib.Error):String {
		return e != null && e.message != null ? e.message : "unknown http error";
	}
}
#end
