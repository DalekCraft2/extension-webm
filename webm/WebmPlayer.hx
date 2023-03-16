package webm;

import haxe.io.Bytes;
import haxe.io.BytesData;
import lime.media.AudioBuffer;
import lime.media.vorbis.VorbisFile;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;
import openfl.events.Event;
import openfl.events.SampleDataEvent;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.utils.ByteArray;
import openfl.utils.Endian;

using Std;

class WebmPlayer extends Bitmap {
	static inline var BYTES_PER_SAMPLE:Int = 4 * 8192;
	static var BLANK_BYTES:ByteArray;
	static var SKIP_STEP_LIMIT:Int = 0;

	public var frameRate(default, null):Float;
	public var duration(default, null):Float;

	public var disposeOnComplete:Bool = true;

	var vpxDecoder:VpxDecoder;
	var webmDecoder:WebmDecoder;
	var outputSound:ByteArray;
	var soundChannel:SoundChannel;
	var sound:Sound;
	var soundEnabled:Bool;
	var skippedSteps:Int = 0;

	var startTime:Float = 0.0;
	var lastDecodedVideoFrame:Float = 0.0;
	var lastRequestedVideoFrame:Float = 0.0;
	var playing:Bool = false;
	var renderedCount:Int = 0;

	public function new(io:WebmIo, soundEnabled:Bool = true) {
		super(null);

		this.soundEnabled = soundEnabled;

		if (BLANK_BYTES == null) {
			BLANK_BYTES = new ByteArray(BYTES_PER_SAMPLE);
		}

		pixelSnapping = PixelSnapping.AUTO;
		smoothing = true;

		vpxDecoder = new VpxDecoder();

		webmDecoder = new WebmDecoder(io.io, soundEnabled);

		var info = webmDecoder.getInfo();
		bitmapData = new BitmapData(info[0].int(), info[1].int(), false, 0);
		frameRate = info[2];
		duration = info[3];

		if (soundEnabled) {
			outputSound = new ByteArray();
			outputSound.endian = Endian.LITTLE_ENDIAN;
		}
	}

	public function getElapsedTime():Float {
		return haxe.Timer.stamp() - startTime;
	}

	public function restart() {
		stop(true);
		renderedCount = 0;
		lastDecodedVideoFrame = 0;
		webmDecoder.restart();
		this.dispatchEvent(new Event(WebmEvent.RESTART));
		play();
	}

	public function play() {
		if (!playing) {
			startTime = haxe.Timer.stamp();

			if (soundEnabled) {
				sound = new Sound();
				sound.addEventListener(SampleDataEvent.SAMPLE_DATA, generateSound);
				soundChannel = sound.play();
			}

			addEventListener(Event.ENTER_FRAME, onSpriteEnterFrame);
			playing = true;
			dispatchEvent(new WebmEvent(WebmEvent.PLAY));
		}
	}

	public function stop(?pRestart:Bool = false) {
		if (playing) {
			playing = false;
			if (!pRestart) {
				dispatchEvent(new WebmEvent(WebmEvent.STOP));
				dispose();
			}
		}
	}

	public function dispose() {
		removeEventListener(Event.ENTER_FRAME, onSpriteEnterFrame);

		if (sound != null) {
			sound.removeEventListener(SampleDataEvent.SAMPLE_DATA, generateSound);
			sound.close();
			sound = null;
		}

		if (soundChannel != null) {
			soundChannel.stop();
			soundChannel = null;
		}

		if (bitmapData != null) {
			bitmapData.dispose();
			bitmapData = null;
		}
	}

	function generateSound(e:SampleDataEvent) {
		var totalOutputLength = outputSound.length;
		var outputBytesToWrite = Math.min(totalOutputLength, BYTES_PER_SAMPLE).int();
		var blankBytesToWrite = BYTES_PER_SAMPLE - outputBytesToWrite;

		if (blankBytesToWrite > 0)
			e.data.writeBytes(BLANK_BYTES, 0, blankBytesToWrite);

		if (outputBytesToWrite > 0) {
			e.data.writeBytes(outputSound, 0, outputBytesToWrite);

			if (outputBytesToWrite < totalOutputLength) {
				var remainingBytes = new ByteArray();
				remainingBytes.writeBytes(outputSound, outputBytesToWrite);
				outputSound = remainingBytes;
			} else {
				outputSound.clear();
			}
		}
	}

	function onSpriteEnterFrame(e:Event) {
		skippedSteps = 0;
		stepVideoFrame();
	}

	function stepVideoFrame() {
		var startRenderedCount = renderedCount;
		var elapsedTime = getElapsedTime();

		while (webmDecoder.hasMore() && lastDecodedVideoFrame < elapsedTime) {
			lastRequestedVideoFrame = elapsedTime;
			webmDecoder.step(decodeVideoFrame, outputAudioFrame);
			if (renderedCount > startRenderedCount)
				break;
		}

		if (!webmDecoder.hasMore()) {
			dispatchEvent(new WebmEvent(WebmEvent.COMPLETE));
			if (disposeOnComplete) {
				stop();
			}
		}
	}

	function decodeVideoFrame(time:Float, data:BytesData) {
		lastDecodedVideoFrame = time;
		++renderedCount;

		vpxDecoder.decode(data);

		if (skippedSteps < SKIP_STEP_LIMIT && playing && lastDecodedVideoFrame < lastRequestedVideoFrame) {
			skippedSteps++;
			stepVideoFrame();
		} else {
			vpxDecoder.getAndRenderFrame(bitmapData);
		}
	}

	function outputAudioFrame(time:Float, data:BytesData) {
		if (!soundEnabled)
			return;
		outputSound.position = outputSound.length;
		outputSound.writeBytes(ByteArray.fromBytes(Bytes.ofData(data)));
		outputSound.position = 0;
	}
}
