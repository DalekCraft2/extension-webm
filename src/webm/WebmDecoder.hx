package webm;

import lime.system.System;
import haxe.io.BytesData;

class WebmDecoder {
	private var context:WebmDecoderContext;

	public function new(io:Dynamic, soundEnabled:Bool) {
		context = hx_webm_decoder_create(io, soundEnabled);
	}

	public function getInfo():Array<Float> {
		return hx_webm_decoder_get_info(context);
	}

	public function hasMore():Bool {
		return hx_webm_decoder_has_more(context);
	}

	public function step(decodeVideo:(Float, BytesData) -> Void, decodeAudio:(Float, BytesData) -> Void):Void {
		hx_webm_decoder_step(context, decodeVideo, decodeAudio);
	}

	public function restart():Void {
		hx_webm_decoder_restart(context);
	}

	static var hx_webm_decoder_create:(ioValue:Dynamic, audioEnabled:Bool) -> WebmDecoderContext = System.load("extension-webm", "hx_webm_decoder_create", 2);
	static var hx_webm_decoder_get_info:(context:WebmDecoderContext) -> Array<Float> = System.load("extension-webm", "hx_webm_decoder_get_info", 1);
	static var hx_webm_decoder_has_more:(context:WebmDecoderContext) -> Bool = System.load("extension-webm", "hx_webm_decoder_has_more", 1);
	static var hx_webm_decoder_step:(context:WebmDecoderContext, decodeVideo:(Float, BytesData) -> Void, decodeAudio:(Float, BytesData) -> Void) -> Void = System.load("extension-webm", "hx_webm_decoder_step", 3);
	static var hx_webm_decoder_restart:(context:WebmDecoderContext) -> Void = System.load("extension-webm", "hx_webm_decoder_restart", 1);
}

typedef WebmDecoderContext = Dynamic;
