package;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.input.FlxPointer;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
using flixel.util.FlxSpriteUtil;

class PlayState extends FlxTransitionableState
{
	public var gameIsOver = false;
	var _bg:FlxSprite;
	var _canvas:FlxSprite;
	var _grpVertex:FlxTypedGroup<Vertex>;
	var _grpEdge:FlxTypedGroup<Edge>;
	var _selectedVertex:Vertex;
	var _targetVertex:Vertex;

	//HUD
	var _txtTitle:FlxText;
	var _txtEdges:FlxText;
	var _txtGameOver:FlxText;
	var _grpHUD:FlxTypedGroup<FlxSprite>;

	//Keep count
	var _edgesToWin:Int;
	var _dirtyCanvas:Bool = false;

	var _highlightVertex:FlxSprite;
	var _pointerBounds:FlxObject;

	override public function create():Void
	{
		super.create();

		SizeInfo.setup();

		//Transition prototype
		transIn = new TransitionData();
		transOut = new TransitionData();
		transIn.duration = 0.3;
		transOut.duration = 0.3;

		FlxTransitionableState.defaultTransIn = transIn;
		FlxTransitionableState.defaultTransOut = transOut;

		_bg = new FlxSprite();
		_bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE, true);
		add(_bg);

		//Canvas
		_canvas = new FlxSprite();
		_canvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		add(_canvas);

		_highlightVertex = new FlxSprite();
		_highlightVertex.makeGraphic(24, 24, FlxColor.GRAY, true);
		_highlightVertex.visible = false;
		add(_highlightVertex);

		//Vertex
		_grpVertex = new FlxTypedGroup<Vertex>();
		add(_grpVertex);
		loadLevel();

		//Edges
		_grpEdge = new FlxTypedGroup<Edge>();
		add(_grpEdge);

		_pointerBounds = new FlxObject(0, 0, 1, 1);
		_pointerBounds.visible = false;
		add(_pointerBounds);


		//HUD
		_grpHUD = new FlxTypedGroup<FlxSprite>();
		_txtEdges = new FlxText(0, 0, FlxG.width * 0.25, "0", 32);
		_txtEdges.alignment = FlxTextAlign.CENTER;
		_txtEdges.color = FlxColor.BLACK;
		_txtEdges.screenCenter(FlxAxes.X);
		_txtEdges.y = FlxG.height * 0.05;
		_grpHUD.add(_txtEdges);

		_txtGameOver = new FlxText(0, 0, FlxG.width, "YOU WIN!", 32);
		_txtGameOver.alignment = FlxTextAlign.CENTER;
		_txtGameOver.color = FlxColor.BLACK;
		_txtGameOver.screenCenter(FlxAxes.XY);
		_txtGameOver.visible = false;
		_grpHUD.add(_txtGameOver);
		add(_grpHUD);


		FlxG.watch.add(Reg, "levelIndex");
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		updateInteface();
		updateInput();
		if (!gameIsOver) {
			updateWinCondition();
		}
	}

	function loadLevel()
	{
		var level:Level = null;
		if (Reg.playEditorLevel)
		{
			level = Reg.levelInfo.editorLevel;
		}
		else if (Reg.levelIndex >= 0 && Reg.levelIndex < Reg.levelInfo.levels.length)
		{
			level = Reg.levelInfo.levels[Reg.levelIndex];
		}
		// Actually loads the level
		if (level != null)
		{
			var index = 0;
			for (v in level.vertices) {
				var vertex = new Vertex();
				vertex.setPosition(Math.floor(v.x * FlxG.width - vertex.width/2), Math.floor(v.y * FlxG.height - vertex.height/2));
				_grpVertex.add(vertex);
				index ++;
				FlxG.watch.add(vertex, "width", "vertex" + index);
			}
			_edgesToWin = level.edgesToWin;
		}
		else
		{
			FlxG.log.add("invalid level index");
		}
	}

	function updateInteface()
	{
		_txtEdges.text = Std.string(_edgesToWin);
		
		if (Reg.levelIndex >= Reg.levelInfo.levels.length) {
			_txtGameOver.visible = true;
			_txtGameOver.text = "YOU WIN!";
			_txtEdges.visible = false;
			gameIsOver = true;
		}
	}

	function updateInput()
	{
		#if !FLX_NO_KEYBOARD
		#if !FLX_NO_DEBUG
		if (FlxG.keys.justReleased.R)
		{
			restartLevel();
		}
		else if (FlxG.keys.justReleased.UP || FlxG.keys.justReleased.W)
		{
			Reg.levelIndex ++;
			restartLevel();
		}
		else if (FlxG.keys.justReleased.DOWN || FlxG.keys.justReleased.S)
		{
			Reg.levelIndex --;
			restartLevel();
		}
		else if (FlxG.keys.justReleased.ESCAPE)
		{
			selectMenu();
		}
		#end
		#end

		var pointer:FlxPointer = null;

		#if !FLX_NO_MOUSE
		setPointerBoundsPosition(FlxG.mouse.getWorldPosition());
		
		if (FlxG.mouse.justReleased) {
			var vertex = pointerOverlapsVertex();
			clearCanvas();
			unselectVertex(_selectedVertex);
			if (vertex != null) {
				chooseVertex(vertex);
			}
		}
		else if (_selectedVertex != null) {
			var vertex = pointerOverlapsVertex();
			clearCanvas();
			if (vertex != null) {
				chooseVertex(vertex);
			} 
			else {
				drawLineToPoint(_pointerBounds.getPosition());
			}
		}		

		#end

		#if !FLX_NO_TOUCH

		if (FlxG.swipes != null && FlxG.swipes.length > 0)
		{
			var swipe = FlxG.swipes[0];
			if (Math.abs(swipe.startPosition.x - swipe.endPosition.x) > FlxG.width * 0.25)
				{
				if (swipe.startPosition.x < swipe.endPosition.x) {
					Reg.levelIndex --;
				}
				else {
					Reg.levelIndex ++;
				}
				restartLevel();
			}
		}
		
		if (FlxG.touches.list != null && FlxG.touches.list.length > 0) {
			var touch = FlxG.touches.list[0];
			setPointerBoundsPosition(touch.getWorldPosition());
			pointer = touch;
			clearCanvas();
			if (!touch.justReleased) {
				var vertex = pointerOverlapsVertex();
				if (vertex != null) {
					chooseVertex(vertex);
				} 
				else {
					drawLineToPoint(_pointerBounds.getPosition());
				}
			}
			else {
				unselectVertex(_selectedVertex);
			}
		}

		#end
	}

	function setPointerBoundsPosition(point:FlxPoint)
	{
		_pointerBounds.x = point.x + Math.floor(_pointerBounds.width /2);
		_pointerBounds.y = point.y + Math.floor(_pointerBounds.height /2);
	}

	function clearCanvas() 
	{
		if (_dirtyCanvas) {
			_canvas.fill(_bg.color);
			_dirtyCanvas = false;
		}	
	}

	function drawLineToPoint(point:FlxPoint)
	{
		if (_selectedVertex != null && point != null) {
			var linestyle = { color: FlxColor.BLACK, thickness: SizeInfo.LINE_WIDTH };
			_canvas.drawLine(_selectedVertex.x + _selectedVertex.width/2, _selectedVertex.y + _selectedVertex.height/2,
			 point.x, point.y, linestyle);
			_dirtyCanvas = true;
		}
	}

	function pointerOverlapsVertex():Vertex
	{
		var vertex = null;
		FlxG.overlap(_pointerBounds, _grpVertex, function(p:FlxObject, v:Vertex){ vertex = v; });
		return vertex;
	}

	function updateWinCondition()
	{
		if (_grpVertex.length > 0 && _edgesToWin <= 0) {
			goToNextLevel();
		}
	}

	function edgeCrosses(e:Edge):Bool
	{
		var crosses = false;
		var index = 0;
		_grpEdge.forEachAlive(function (other:Edge) {
			index ++;
			FlxG.log.add("test edge #" + index);
			if (e.intercepts(other)) {
				crosses = true;
			}
		});
		return crosses;
	}

	function gameOver()
	{
		gameIsOver = true;
		transOut.color = FlxColor.RED;
		FlxTransitionableState.defaultTransIn.color = FlxColor.RED;
		FlxTransitionableState.defaultTransIn.color = FlxColor.RED;
		restartLevel();
	}

	function selectMenu():Void
	{
		FlxG.switchState(new MenuState());
	}

	function goToNextLevel()
	{
		Reg.levelIndex ++;
		transOut.color = FlxColor.GREEN;
		FlxTransitionableState.defaultTransIn.color = FlxColor.GREEN;
		FlxTransitionableState.defaultTransOut.color = FlxColor.GREEN;
		restartLevel();
	}

	function chooseVertex(vertex:Vertex)
	{
		if (_selectedVertex != null && _selectedVertex == vertex) {
			return;
		}
		else if (_selectedVertex != null) {
			if (!existsEdge(_selectedVertex,vertex)) {
				connectVertices(_selectedVertex, vertex);
			}
			unselectVertex(_selectedVertex);
			selectVertex(vertex);
		}
		else {
			selectVertex(vertex);
			FlxG.log.add("show selection");
		}
	}

	function selectVertex(v:Vertex)
	{
		_selectedVertex = v;
		if (v != null) {
			v.select();
		}
	}

	function unselectVertex(v:Vertex)
	{
		_selectedVertex = null;
		if (v != null) {
			v.unselect();
		}
	}

	function connectVertices(origin:Vertex, target:Vertex)
	{
		var edge = new Edge();
		edge.connectVertices(origin, target);
		origin.edges.add(edge);
		target.edges.add(edge);
		_grpEdge.add(edge);
		if (edgeCrosses(edge)) {
			gameOver();
		}
		else {
			_edgesToWin --;
		}

		FlxG.log.add("connect");
	}

	function existsEdge(origin:Vertex, target:Vertex):Bool
	{
		var exists = false;
		_grpEdge.forEach(function (e:Edge) {
			if ((e.startVertex == origin && e.endVertex == target)
			 || (e.startVertex == target && e.endVertex == origin)) 
			{
				exists = true;
				return;
			}
		});
		return exists;
	}

	function restartLevel() {
		FlxG.switchState(new PlayState());
	}
}
