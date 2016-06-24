package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.input.FlxPointer;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxAxes;

class MenuState extends FlxState
{
	var _grpHUD:FlxTypedGroup<FlxSprite>;
	var _txtTitle:FlxText;
	var _txtPlay:FlxText;
	var _txtLevels:FlxText;
	var _txtEditor:FlxText;

	override public function create():Void
	{
		super.create();

		SizeInfo.setup();
		Reg.playEditorLevel = false;

		_grpHUD = new FlxTypedGroup<FlxSprite>();
		add(_grpHUD);

		_txtTitle = new FlxText(0, 0, FlxG.width, "Don't Cross\n The line", SizeInfo.TITLE_FONT);
		_txtTitle.alignment = FlxTextAlign.CENTER;
		_txtTitle.screenCenter(FlxAxes.X);
		_txtTitle.y = FlxG.height * 0.15;
		_grpHUD.add(_txtTitle);

		_txtPlay = new FlxText(0, 0, FlxG.width, "Play", SizeInfo.OPTION_FONT);
		_txtPlay.alignment = FlxTextAlign.CENTER;
		_txtPlay.screenCenter(FlxAxes.X);
		_txtPlay.y = _txtTitle.y + _txtTitle.height + FlxG.height * 0.25;
		_grpHUD.add(_txtPlay);

		_txtLevels = new FlxText(0, 0, FlxG.width, "Levels", SizeInfo.OPTION_FONT);
		_txtLevels.alignment = FlxTextAlign.CENTER;
		_txtLevels.screenCenter(FlxAxes.X);
		_txtLevels.y = _txtPlay.y + _txtPlay.height + FlxG.height * 0.10;
		_grpHUD.add(_txtLevels);

		_txtEditor = new FlxText(0, 0, FlxG.width, "Level editor", SizeInfo.OPTION_FONT);
		_txtEditor.alignment = FlxTextAlign.CENTER;
		_txtEditor.screenCenter(FlxAxes.X);
		_txtEditor.y = _txtLevels.y + _txtLevels.height + FlxG.height * 0.10;
		_grpHUD.add(_txtEditor);

		_grpHUD.forEach(function(spr:FlxSprite){
			spr.scrollFactor.set();
		});
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		updateInput();
	}

	function updateInput()
	{
		#if !FLX_NO_KEYBOARD
		if (FlxG.keys.justReleased.P || FlxG.keys.justReleased.SPACE)
		{
			selectPlay();
		}
		else if (FlxG.keys.justReleased.L)
		{
			selectLevels();
		}
		else if (FlxG.keys.justReleased.E)
		{
			selectEditor();
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
			if (pointer.overlaps(_txtPlay))
			{
				selectPlay();
				return;
			}
			else if (pointer.overlaps(_txtLevels))
			{
				selectLevels();
				return;
			}
			else if (pointer.overlaps(_txtEditor))
			{
				selectEditor();
				return;
			}
		}
	}

	function selectPlay()
	{
		FlxG.switchState(new PlayState());
	}

	function selectLevels()
	{
		FlxG.switchState(new LevelsState());
	}

	function selectEditor()
	{
		FlxG.switchState(new EditorState());
	}
}
