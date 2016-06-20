package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		Reg.setup();
		addChild(new FlxGame(640, 480, PlayState));
	}
}