package webm;

import lime.system.System;
import haxe.io.BytesData;

class WebmIo {
	public var io:Dynamic;

	public function new() {}

	function create() {
		io = hx_create_io(read, seek, tell);
	}

	function read(count:Int):BytesData {
		return null;
	}

	function seek(offset:Float, whence:Int):Int {
		return 0;
	}

	function tell():Float {
		return 0;
	}

	static var hx_create_io:(read:(count:Int) -> BytesData, seek:(offset:Float, whence:Int) -> Int, tell:() -> Float) -> Dynamic = System.load("extension-webm", "hx_create_io", 3);
}
