package states;

import backend.WeekData;
import backend.Highscore;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import states.MainMenuState;
import flixel.addons.transition.FlxTransitionableState;

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	static var passedWarning:Bool = false;

	var logo:FlxSprite;
	var titleStuff:FlxTypedGroup<FlxSprite>;

	override function create():Void
	{
		Paths.clearStoredMemory();
		FlxG.mouse.visible = false;

		#if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];
		FlxG.camera.bgColor = 0xFFFFFF;

		FlxG.save.bind('funkin', CoolUtil.getSavePath());
		ClientPrefs.loadPrefs();
		Highscore.load();

		if(FlxG.save.data != null && FlxG.save.data.fullscreen) FlxG.fullscreen = FlxG.save.data.fullscreen;
		persistentUpdate = true;
		persistentDraw = true;

		if (FlxG.save.data.weekCompleted != null)
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;

		if(FlxG.save.data.flashing == null && !WarningState.leftState) {
            FlxTransitionableState.skipNextTransIn = true;
            FlxTransitionableState.skipNextTransOut = true;
            new FlxTimer().start(1, function(_) {
				FlxG.switchState(() -> new WarningState());
			});
			passedWarning = true;
			allow = false;
            return;
        }

		if(passedWarning) {
			FlxTween.cancelTweensOf(FlxG.camera);
			FlxG.camera.scroll.y = -FlxG.height;
			FlxTween.tween(FlxG.camera, {"scroll.y": 0}, 1.25, {ease: FlxEase.smootherStepOut});
		}

		if(FlxG.sound.music == null) {
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxG.sound.music.fadeIn(4, 0, 1);
		}
		Conductor.bpm = 109;

		var bg:FlxSprite = new FlxSprite();
		bg.antialiasing = false;
		bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		bg.scrollFactor.set(0, 0);
		add(bg);

		titleStuff = new FlxTypedGroup<FlxSprite>();
		add(titleStuff);

		var red:FlxSprite = new FlxSprite().loadGraphic(Paths.image('title/red'));
		red.antialiasing = false;
		red.x = 75;
		red.y = FlxG.height - red.height - 125;
		red.updateHitbox();
		titleStuff.add(red);

		var enter:FlxSprite = new FlxSprite().loadGraphic(Paths.image('title/press'));
		enter.antialiasing = false;
		enter.screenCenter();
		enter.y += 325;
		enter.updateHitbox();
		titleStuff.add(enter);

		logo = new FlxSprite(0, 35).loadGraphic(Paths.image('title/logo'));
		logo.scale.set(0.6, 0.6);
		logo.updateHitbox();
		logo.x = FlxG.width - logo.width - 80;
		logo.antialiasing = false;
		titleStuff.add(logo);

		super.create();
		Paths.clearUnusedMemory();
	}

	var selected:Bool = false;
	var allow:Bool = true;
	override function update(elapsed:Float)
	{
		if(!allow) return;

		if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;

		var mult:Float = FlxMath.lerp(0.6, logo.scale.x, Math.exp(-elapsed * 9 * 1));
		logo.scale.set(mult, mult);

		if(FlxG.keys.justPressed.ENTER && !selected)
		{
			selected = true;
			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
			for(item in titleStuff.members) 
				FlxTween.tween(item, {y: item.y + 1000}, 1.25, {ease: FlxEase.smootherStepIn, startDelay: 0.06});

			new FlxTimer().start(1.3, function(_) {
				FlxG.switchState(() -> new MainMenuState());
			});
		}

		super.update(elapsed);
	}

	override function beatHit()
	{
		logo.scale.set(0.65, 0.65);

		super.beatHit();
	}
}
