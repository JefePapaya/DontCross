package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
using flixel.util.FlxSpriteUtil;

class Edge extends FlxSprite
{
	public var startVertex:Vertex;
	public var endVertex:Vertex;
	public var startPoint:FlxPoint;
	public var endPoint:FlxPoint;

	override public function new(?X:Float = 0, ?Y:Float = 0)
	{
		super(X, Y);

	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function connectVertices(origin:Vertex, target:Vertex)
	{
		var lineStyle = { color: FlxColor.BLACK, thickness: SizeInfo.LINE_WIDTH };
		var fillStyle = { color: FlxColor.BLACK };
		if (origin.x <= target.x) {
			startPoint = new FlxPoint(origin.x + origin.width/2, origin.y + origin.height/2);
			endPoint = new FlxPoint(target.x + target.width/2, target.y + target.height/2);
		}
		else {
			startPoint = new FlxPoint(target.x + target.width/2, target.y + target.height/2);
			endPoint = new FlxPoint(origin.x + origin.width/2, origin.y + origin.height/2);	
		}
		makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		drawLine(startPoint.x, startPoint.y, endPoint.x, endPoint.y, lineStyle);
		startVertex = origin;
		endVertex = target;
	}

	public function intercepts(other:Edge):Bool
	{
		if (this == other) {
			FlxG.log.add("same vertex");
			return false;
		}

		var sprIntercept = new FlxSprite();
		sprIntercept.makeGraphic(SizeInfo.VERTEX_WIDTH, SizeInfo.VERTEX_HEIGHT, FlxColor.MAGENTA);
		// sprIntercept.drawCircle(SizeInfo.VERTEX_WIDTH/2, SizeInfo.VERTEX_HEIGHT/2, SizeInfo.VERTEX_WIDTH/2, FlxColor.MAGENTA);

		var deltaX = deltaX();
		var deltaY = deltaY();
		var otherDeltaX = other.deltaX();
		var otherDeltaY = other.deltaY();

		if (deltaX == 0 && otherDeltaX == 0) {
			FlxG.log.add("both deltas are equal");
			return false;
		}
		else if (deltaX == 0) {
			var otherSlope = otherDeltaY / otherDeltaX;
			var interceptY = otherSlope * startPoint.x + other.constant(otherSlope);
			FlxG.log.add("interceptY " + interceptY);
			if ((Math.min(other.startPoint.x, other.endPoint.x) < startPoint.x && Math.max(other.startPoint.x, other.endPoint.x) > startPoint.x) &&
				(interceptY > Math.min(startPoint.y, endPoint.y) && interceptY < Math.max(startPoint.y, endPoint.y)))
			{
				FlxG.log.add("this 0 slope intercept");
				sprIntercept.setPosition(startPoint.x, interceptY);
				FlxG.state.add(sprIntercept);
				return true;
			}
			FlxG.log.add("this slope 0 no intercept");
			return false;
		}
		else if (otherDeltaX == 0) {
			var slope = deltaY / deltaX;
			var interceptY = slope * other.startPoint.x + constant(slope);
			FlxG.log.add("interceptY " + interceptY);
			if ((Math.min(startPoint.x, endPoint.x) < other.startPoint.x && Math.max(startPoint.x, endPoint.x) > other.startPoint.x) &&
				(interceptY > Math.min(other.startPoint.y, other.endPoint.y) && interceptY < Math.max(other.startPoint.y, other.endPoint.y)))
			{
				FlxG.log.add("other 0 slope intercept");
				sprIntercept.setPosition(other.startPoint.x, interceptY);
				FlxG.state.add(sprIntercept);
				return true;
			}
			FlxG.log.add("other slope 0 no intercept");
			return false;
		}

		var slope = deltaY / deltaX;
		var otherSlope = otherDeltaY / otherDeltaX;
		var constant = constant(slope);
		var otherConstant = other.constant(otherSlope);

		var deltaSlope = slope - otherSlope;
		if (deltaSlope == 0) {
			FlxG.log.add("delta slope == 0");
			return false;
		}
		var interceptX = (otherConstant - constant) / deltaSlope;
		if (interceptX > startPoint.x && interceptX < endPoint.x && 
			interceptX > other.startPoint.x && interceptX < other.endPoint.x) {
			FlxG.log.add("regular intercept");
			sprIntercept.setPosition(interceptX, slope * interceptX + constant);
			FlxG.state.add(sprIntercept);
			return true;
		}
		else {
			FlxG.log.add("regular no intercept");
			return false;
		}
	}

	public function deltaX():Float
	{
		return endPoint.x - startPoint.x;
	}

	public function deltaY():Float
	{
		return endPoint.y - startPoint.y;	
	}

	public function constant(slope:Float):Float
	{
		return startPoint.y - slope * startPoint.x;
	}
}