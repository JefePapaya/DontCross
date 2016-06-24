package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.input.FlxPointer;
import flixel.text.FlxText;
import flixel.util.FlxAxes;

class LevelsState extends FlxState
{
	var _txtTitle:FlxText;
	var _txtBack:FlxText;
	var _grpHUD:FlxTypedGroup<FlxSprite>;

	public override function create():Void
	{
		super.create();

		_grpHUD = new FlxTypedGroup<FlxSprite>();
		add(_grpHUD);

		_txtTitle = new FlxText(0, 0, FlxG.width, "Nothing to see here...", SizeInfo.TITLE_FONT);
		_txtTitle.alignment = FlxTextAlign.CENTER;
		_txtTitle.screenCenter(FlxAxes.XY);
		_grpHUD.add(_txtTitle);

		_txtBack = new FlxText(0, 0, FlxG.width, "go back", SizeInfo.TITLE_FONT);
		_txtBack.alignment = FlxTextAlign.CENTER;
		_txtBack.screenCenter(FlxAxes.X);
		_txtBack.y = _txtTitle.y + _txtTitle.height + FlxG.height * 0.25;
		_grpHUD.add(_txtBack);

		_grpHUD.forEach(function (spr: FlxSprite){
			spr.scrollFactor.set();
		});
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		updateInput();
	}

	function updateInput():Void
	{
		#if !FLX_NO_KEYBOARD
		if (FlxG.keys.justReleased.B || FlxG.keys.justReleased.SPACE)
		{
			selectBack();
		}
		#end
		
		var pointer:FlxPointer = null;

		#if !FLX_NO_MOUSE
		if (FlxG.mouse.justReleased) {
			pointer = FlxG.mouse;
		}
		#end

		#if !FLX_NO_TOUCH
		if (FlxG.touches.justReleased() != null && FlxG.touches.justReleased().length > 0) {
			pointer = FlxG.touches.justReleased()[FlxG.touches.justReleased().length - 1];
		}
		#end

		if (pointer != null) 
		{
			if (pointer.overlaps(_txtBack))
			{
				selectBack();
				return;
			}
		}
	}

	function selectBack()
	{
		FlxG.switchState(new MenuState());
	}
}