package webm;

import openfl.events.Event;
import openfl.events.EventType;

class WebmEvent extends Event {
	public static inline var PLAY:EventType<WebmEvent> = "play";
	public static inline var STOP:EventType<WebmEvent> = "stop";
	public static inline var COMPLETE:EventType<WebmEvent> = "complete";
	public static inline var RESTART:EventType<WebmEvent> = "restart";

	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false) {
		super(type, bubbles, cancelable);
	}
}
