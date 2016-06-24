package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.input.FlxPointer;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
using flixel.util.FlxSpriteUtil;

class EditorState extends  FlxState
{
	private var _txtTitle:FlxText;
	private var _bg:FlxSprite;
	private var _grid:FlxSprite;
	private var _grpLines:FlxTypedGroup<FlxSprite>;
	private var _grpVertex:FlxTypedGroup<Vertex>;
	private var _grpHUD:FlxTypedGroup<FlxSprite>;
	private var _txtPlay:FlxText;
	private var _txtSave:FlxText;
	private var _canvas:FlxSprite;

	private var _lineCount:Int;
	private var _columnCount:Int;

	private var _level:Level;

	override public function create():Void
	{
		super.create();

		_level = new Level();
		_grpHUD = new FlxTypedGroup<FlxSprite>();

		_bg = new FlxSprite();
		_bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE, true);
		add(_bg);

		_txtTitle = new FlxText(0, 0, FlxG.width, "Level Editor", SizeInfo.TITLE_FONT);
		_txtTitle.alignment = FlxTextAlign.CENTER;
		_txtTitle.color = FlxColor.BLACK;
		_txtTitle.screenCenter(FlxAxes.X);
		_txtTitle.y = FlxG.height * 0.15;
		_grpHUD.add(_txtTitle);

		_txtPlay = new FlxText(0, 0, FlxG.width, "try it!", SizeInfo.TITLE_FONT);
		_txtPlay.alignment = FlxTextAlign.CENTER;
		_txtPlay.color = FlxColor.BLACK;
		_txtPlay.screenCenter(FlxAxes.X);
		_txtPlay.y = FlxG.height * 0.8;
		_grpHUD.add(_txtPlay);

		_txtSave = new FlxText(0, 0, FlxG.width, "save", SizeInfo.TITLE_FONT);
		_txtSave.alignment = FlxTextAlign.CENTER;
		_txtSave.color = FlxColor.BLACK;
		_txtSave.screenCenter(FlxAxes.X);
		_txtSave.y = _txtPlay.y + _txtPlay.height + FlxG.height * 0.05;
		_grpHUD.add(_txtSave);

		_canvas = new FlxSprite();
		_canvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		add(_canvas);

		_grid = new FlxSprite();
		add(_grid);
		drawGrid();

		_grpVertex = new FlxTypedGroup<Vertex>();
		add(_grpVertex);

		_grpHUD.forEach(function(spr:FlxSprite){
			spr.scrollFactor.set();
		});
		add(_grpHUD);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		// updateInteface();
		updateInput();
	}

	private function drawGrid():Void
	{
		_lineCount = Math.floor(Math.min(FlxG.width, FlxG.height) / SizeInfo.VERTEX_WIDTH);
		_columnCount = _lineCount;
		var editorWidth:Int = (_lineCount - 1) * SizeInfo.VERTEX_WIDTH;
		var startX = (FlxG.width - editorWidth) / 2;
		var startY = (FlxG.height - editorWidth) / 2;
		_grid.makeGraphic(editorWidth, editorWidth, FlxColor.WHITE, true);
		_grid.setPosition(startX, startY);

		var linestyle = { color: FlxColor.GRAY, thickness: 2.0 }

		for (i in 0..._lineCount) {
			var posY = i * SizeInfo.VERTEX_WIDTH;
			_grid.drawLine(0, posY, editorWidth, posY, linestyle);
		}
		for (j in 0..._columnCount) {
			var posX = j * SizeInfo.VERTEX_WIDTH;
			_grid.drawLine(posX, 0, posX, editorWidth, linestyle);
		}
		FlxG.log.add("lineCount = " + _lineCount);
	}

	private function updateInput():Void
	{
		#if !FLX_NO_KEYBOARD
		if (FlxG.keys.justReleased.P || FlxG.keys.justReleased.SPACE)
		{
			// selectPlay();
		}
		else if (FlxG.keys.justReleased.P)
		{
			selectPlay();
		}
		else if (FlxG.keys.justReleased.S)
		{
			saveLevelInfo();
		}
		else if (FlxG.keys.justReleased.ESCAPE)
		{
			selectMenu();
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
			if (pointer.overlaps(_txtSave))
			{
				saveLevelInfo();
			}
			else if (pointer.overlaps(_txtPlay))
			{
				selectPlay();
			}
			else if (pointer.overlaps(_grpVertex))
			{
				eraseVertexAtPoint(pointer.getWorldPosition());
			}
			else if (pointer.overlaps(_grid))
			{
				clickedGridAtPosition(pointer.getWorldPosition());
			}
		}
	}

	function eraseVertexAtPoint(point:FlxPoint):Void
	{
		var v:Vertex = null;
		_grpVertex.forEachAlive(function(spr:Vertex)
		{
			if (spr.overlapsPoint(point)) {
				v = spr;
				return;
			}
		});
		if (v != null) {
			_grpVertex.remove(v);
		}
	}

	function clickedGridAtPosition(point:FlxPoint):Void
	{
		point.x -= _grid.x;
		point.y -= _grid.y;

		var column = Math.floor(point.x / SizeInfo.VERTEX_WIDTH);
		var line = Math.floor(point.y / SizeInfo.VERTEX_HEIGHT);
		var vertex = new Vertex(_grid.x + column * SizeInfo.VERTEX_WIDTH, _grid.y + line * SizeInfo.VERTEX_HEIGHT);

		_grpVertex.add(vertex);
	}

	function selectMenu():Void
	{
		FlxG.switchState(new MenuState());
	}

	function selectPlay():Void
	{
		saveLevelInfo();	
		Reg.playEditorLevel = true;
		FlxG.switchState(new PlayState());
	}

	function saveLevelInfo():Void
	{
		_grpVertex.forEach(saveVertex);
		_level.edgesToWin = _grpVertex.members.length;
		Reg.levelInfo.editorLevel = _level;
	}

	function saveVertex(v:Vertex):Void
	{
		_level.vertices = new Array<Dynamic>();
		_grpVertex.forEach(function(sv:Vertex) {
			var dict = { x: sv.x / FlxG.width, y: sv.y / FlxG.height };
			_level.vertices.push(dict);
		});
	}
}