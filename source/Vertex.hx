package;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
using flixel.util.FlxSpriteUtil;

class Vertex extends FlxSprite
{
	public var selected:Bool = false;
	public var edges:FlxTypedGroup<Edge>;
	var _highlight:FlxSprite;


	override public function new(?X:Float = 0, ?Y:Float = 0)
	{
		super(X, Y);
		makeGraphic(16, 16, FlxColor.BLACK);

		_highlight = new FlxSprite();
		_highlight.makeGraphic(32, 32, FlxColor.GRAY, true);
		_highlight.visible = false;
		edges = new FlxTypedGroup<Edge>();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		_highlight.update(elapsed);
	}

	override public function draw()
	{
		if (_highlight.visible) {
			_highlight.draw();
		}
		super.draw();
	}

	public function select()
	{
		selected = true;
		_highlight.visible = true;
		_highlight.x = x - (_highlight.width - width)/2;
		_highlight.y = y - (_highlight.height - height)/2;
	}

	public function unselect()
	{
		selected = false;
		_highlight.visible = false;
	}
}