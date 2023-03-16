package webm;

import cpp.Lib;
import haxe.io.BytesData;
import openfl.utils.ByteArray;

class WebmDecoder {
	private var context:Dynamic;

	public function new(io:Dynamic, soundEnabled:Bool) {
		context = hx_webm_decoder_create(io, soundEnabled);
	}

	public function getInfo():Array<Float> {
		return hx_webm_decoder_get_info(context);
	}

	public function hasMore():Bool {
		return hx_webm_decoder_has_more(context);
	}

	public function step(decodeVideo:Float->BytesData->Void, decodeAudio:Float->BytesData->Void):Void {
		hx_webm_decoder_step(context, decodeVideo, decodeAudio);
	}

	public function restart():Void {
		hx_webm_decoder_restart(context);
	}

	static var hx_webm_decoder_create:Dynamic->Bool->Dynamic = Lib.load("extension-webm", "hx_webm_decoder_create", 2);
	static var hx_webm_decoder_get_info:Dynamic->Array<Float> = Lib.load("extension-webm", "hx_webm_decoder_get_info", 1);
	static var hx_webm_decoder_has_more:Dynamic->Bool = Lib.load("extension-webm", "hx_webm_decoder_has_more", 1);
	static var hx_webm_decoder_step = Lib.load("extension-webm", "hx_webm_decoder_step", 3);
	static var hx_webm_decoder_restart = Lib.load("extension-webm", "hx_webm_decoder_restart", 1);
}
