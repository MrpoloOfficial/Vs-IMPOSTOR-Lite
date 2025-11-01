package states.stages;

class StageWeek1 extends BaseStage
{
	override function create()
	{
		var bg:BGSprite = new BGSprite('bg/stage/stage', -600, -900, 1, 1);
		bg.scale.set(1.8, 1.8);
		bg.updateHitbox();
		bg.antialiasing = false;
		add(bg);
	}
}