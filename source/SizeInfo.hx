package;

import flixel.FlxG;

class SizeInfo 
{
	public static var VERTEX_WIDTH:Int;
	public static var VERTEX_HEIGHT:Int;
	public static var LINE_WIDTH:Float;
	public static var TITLE_FONT:Int;
	public static var OPTION_FONT:Int;
	static var _inited:Bool = false;

	public static function setup()
	{
		if (!_inited)
		{
			var minDimension = Math.min(FlxG.width, FlxG.height);
			VERTEX_WIDTH = Math.floor(minDimension * 0.05);
			VERTEX_HEIGHT = VERTEX_WIDTH;
			LINE_WIDTH = Math.floor(minDimension * 0.01);
			TITLE_FONT = Math.floor(minDimension/16);
			OPTION_FONT = Math.floor(minDimension/20);
		}
		_inited = true;
	}
}