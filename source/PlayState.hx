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
import flixel.util.FlxColor;
using flixel.util.FlxSpriteUtil;

class PlayState extends FlxTransitionableState
{
	public var gameIsOver = false;
	var _canvas:FlxSprite;
	var _grpVertex:FlxTypedGroup<Vertex>;
	var _grpEdge:FlxTypedGroup<Edge>;
	var _selectedVertex:Vertex;
	var _targetVertex:Vertex;

	var _highlightVertex:FlxSprite;
	var _pointerBounds:FlxObject;

	override public function create():Void
	{
		super.create();

		//Transition prototype
		transIn = new TransitionData();
		transOut = new TransitionData();
		transIn.duration = 0.3;
		transOut.duration = 0.3;

		FlxTransitionableState.defaultTransIn = transIn;
		FlxTransitionableState.defaultTransOut = transOut;

		var bg = new FlxSprite();
		bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE, true);
		add(bg);

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

		_pointerBounds = new FlxObject(0, 0, 4, 4);

		FlxG.watch.add(Reg, "levelIndex");
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		updateInput();
		if (!gameIsOver) {
			updateWinCondition();
		}
	}

	function loadLevel()
	{
		if (Reg.levelIndex >= 0 && Reg.levelIndex < Reg.levelInfo.levels.length)
		{
			var level = Reg.levelInfo.levels[Reg.levelIndex];
			for (v in level.vertices) {
				var vertex = new Vertex();
				vertex.setPosition(v.x * FlxG.width, v.y * FlxG.height);
				_grpVertex.add(vertex);	
			}
		}
		else 
		{
			FlxG.log.add("invalid level index");
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
		#end
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
			_pointerBounds.x = pointer.x + Math.floor(_pointerBounds.width /2);
			_pointerBounds.y = pointer.y + Math.floor(_pointerBounds.height /2);

			if (FlxG.overlap(_pointerBounds, _grpVertex, chooseVertex))
			{
				//select smth
			}
		}
	}

	function updateWinCondition()
	{
		if (_grpVertex.length > 0) {
			var win = true;
			_grpVertex.forEachAlive(function (v:Vertex){
				if (v.edges.length < 2) {
					win = false;
				}
			});
			if (win == true) {
				goToNextLevel();
			}
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

	function goToNextLevel()
	{
		Reg.levelIndex ++;
		transOut.color = FlxColor.GREEN;
		FlxTransitionableState.defaultTransIn.color = FlxColor.GREEN;
		FlxTransitionableState.defaultTransOut.color = FlxColor.GREEN;
		restartLevel();
	}

	function chooseVertex(pointer:FlxObject, vertex:Vertex)
	{
		if (_selectedVertex != null && _selectedVertex == vertex) {
			unselectVertex(vertex);
			FlxG.log.add("hideSelection");
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
		v.select();
	}

	function unselectVertex(v:Vertex)
	{
		_selectedVertex = null;
		v.unselect();
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

	// function showSelection(vertex:FlxSprite)
	// {
	// 	_highlightVertex.visible = true;
	// 	_highlightVertex.x = vertex.x - (_highlightVertex.width - vertex.width)/2;
	// 	_highlightVertex.y = vertex.y - (_highlightVertex.height - vertex.height)/2;
	// }
	// function hideSelection(vertex:FlxSprite)
	// {
	// 	_highlightVertex.visible = false;
	// }

	function restartLevel() {
		FlxG.switchState(new PlayState());
	}
}
