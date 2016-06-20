package;

class LevelInfo 
{
	public var levels:Array<Level>;

	public function new()
	{
		levels = new Array<Level>();

		var level1 = new Level();
		level1.vertices = [{x: 0.33, y: 0.33}, { x: 0.66, y: 0.33 }, { x: 0.5, y: 0.66 }];
		levels.push(level1);

		var level2 = new Level();
		level2.vertices = [{ x: 0.25, y: 0.25 }, { x: 0.75, y: 0.25 }, 
						   { x: 0.25, y: 0.75 }, { x: 0.75, y: 0.75 }];
		levels.push(level2);

		var level3 = new Level();
		level3.vertices = [{ x: 0.40, y: 0.25 }, { x: 0.60, y: 0.25 }, 
						   { x: 0.40, y: 0.75 }, { x: 0.60, y: 0.75 },
						   { x: 0.20, y: 0.50 }, { x: 0.80, y: 0.50 },
						   { x: 0.50, y: 0.50 }];
		levels.push(level3);
	}
}