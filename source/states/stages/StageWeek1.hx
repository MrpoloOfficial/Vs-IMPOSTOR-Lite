package states.stages;

class StageWeek1 extends BaseStage
{
	override function create()
	{
		var bg:BGSprite = new BGSprite('bg/stage/stage', -600, -200, 0.9, 0.9);
		bg.scale.set(2.2, 2.2);
		bg.updateHitbox();
		add(bg);
	}
}