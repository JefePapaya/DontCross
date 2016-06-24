package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.system.scaleModes.RatioScaleMode;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;

class Main extends Sprite
{
	public var gameHeight:Int = 440;
	var _inited = false;

	public function new()
	{
		super();	

		Reg.setup();
				
		#if android
		stage.addEventListener(Event.RESIZE, onResize);
		haxe.Timer.delay(init, 1500);

		#elseif mobile
		init();

		#else
		init();
		#end
	}


	function onResize(_)
	{
		init();
	}

	function init()
	{
		if (!_inited)
		{
			var gameHeight = Lib.current.stage.stageHeight;
			var gameWidth = Lib.current.stage.stageWidth;
			#if desktop
			addChild(new FlxGame(gameWidth, gameHeight, MenuState, 1, 60, 60, true, false));
			#else
			addChild(new FlxGame(gameWidth, gameHeight, MenuState, 1, 60, 60, true, true));
			#end
			FlxG.scaleMode = new RatioScaleMode(true);
		}
		_inited = true;
	}
}