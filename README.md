# extension-webm

OpenFL extension for decoding [WebM](https://www.webmproject.org/) videos (mkv+vp8+vorbis) on CPP.

## Installation

You need Haxe and [OpenFL](https://openfl.org/).

```sh
haxelib install openfl-webm
```

To add it to a Lime or OpenFL project, add this to your project file:

```xml
<haxelib name="openfl-webm" />
```

## Usage

```haxe
var io:WebmIo = new WebmIoFile("c:/projects/test.webm");
var player:WebmPlayer = new WebmPlayer(io, true);
player.addEventListener(WebmEvent.PLAY, function(e) {
	trace("Play!");
});
player.addEventListener(WebmEvent.COMPLETE, function(e) {
	trace("Complete!");
});
player.addEventListener(WebmEvent.STOP, function(e) {
	trace("Stop!");
});
addChild(player);
player.play();
```
