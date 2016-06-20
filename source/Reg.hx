package;

import flixel.util.FlxSave;

/**
 * Registry class handling saves and global variables,
 * kinda like used in Mode by Adam Atomic
 */
class Reg 
{
	public static var save:FlxSave = new FlxSave();
	public static var levelIndex:Int = 0;
	public static var levelInfo:LevelInfo;

	public static function setup()
	{
		save.bind("DontCross");
		levelInfo = new LevelInfo();
	}
}