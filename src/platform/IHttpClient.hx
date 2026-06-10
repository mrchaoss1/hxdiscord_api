package platform;

import haxe.io.Bytes;

typedef HttpRequest = {
	var method:String;
	var url:String;
	var ?headers:Map<String, String>;
	var ?body:haxe.extern.EitherType<String, Bytes>;
}

typedef HttpResponse = {
	var status:Int;
	var headers:Map<String, String>;
	var body:Bytes;
}

interface IHttpClient {
	function request(req:HttpRequest, cb:(err:Null<String>, res:Null<HttpResponse>) -> Void):Void;
}
