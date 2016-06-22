package;

import flixel.FlxG;

class SizeInfo 
{
	public static var VERTEX_WIDTH:Int;
	public static var VERTEX_HEIGHT:Int;
	public static var LINE_WIDTH:Float;

	public static function setup()
	{
		var minDimension = Math.min(FlxG.width, FlxG.height);
		VERTEX_WIDTH = Math.floor(minDimension * 0.05);
		VERTEX_HEIGHT = VERTEX_WIDTH;
		LINE_WIDTH = Math.floor(minDimension * 0.01);
	}
}