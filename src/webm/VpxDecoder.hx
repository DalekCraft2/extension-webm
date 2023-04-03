package webm;

import haxe.io.Bytes;
import haxe.io.BytesData;
import lime.system.System;
import openfl.display.BitmapData;

class VpxDecoder {
	// public static var version(get, never):String;
	// static function get_version():String {
	// 	return hx_vpx_codec_iface_name();
	// }
	private var context:VpxDecoderContext;

	public function new() {
		context = hx_vpx_codec_dec_init();
	}

	public function decode(data:BytesData):Array<Int> {
		return hx_vpx_codec_decode(context, data);
	}

	public function getAndRenderFrame(bitmapData:BitmapData) {
		var info = hx_vpx_codec_get_frame(context);

		if (info != null) {
			var buffer = bitmapData.image.buffer;
			buffer.data.buffer = Bytes.ofData(info[2]);
			buffer.format = ARGB32;
			buffer.premultiplied = true;
			bitmapData.image.format = BGRA32;
			bitmapData.image.version++;
		}
	}

	// static var hx_vpx_codec_iface_name:() -> String = System.load("extension-webm", "hx_vpx_codec_iface_name", 0);
	static var hx_vpx_codec_dec_init:() -> VpxDecoderContext = System.load("extension-webm", "hx_vpx_codec_dec_init", 0);
	static var hx_vpx_codec_decode:(context:VpxDecoderContext, data:BytesData) -> Array<Int> = System.load("extension-webm", "hx_vpx_codec_decode", 2);
	static var hx_vpx_codec_get_frame:(context:VpxDecoderContext) -> Array<Dynamic> = System.load("extension-webm", "hx_vpx_codec_get_frame", 1);
}

typedef VpxDecoderContext = Dynamic;
