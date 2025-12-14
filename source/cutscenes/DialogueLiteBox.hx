package cutscenes;

import flixel.addons.text.FlxTypeText;
import objects.HealthIcon;
import flixel.group.FlxGroup;

import shaders.RGBPalette;

class DialogueLiteBox extends FlxSpriteGroup
{

	var bgFade:FlxSprite;

	public function new(?dialogueList:Array<String>)
	{
		super();
		this.dialogueList = dialogueList;

		dialogueMusic = new FlxSound();
		dialogueMusic.loadEmbedded(Paths.music('dialogues/${PlayState.SONG.song.toLowerCase()}/Inst'), true, true);
		dialogueMusic.volume = 0;
		dialogueMusic.play();
		FlxG.sound.list.add(dialogueMusic);

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB4B4B4);
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			bgFade.alpha += 0.15;
			if (bgFade.alpha > 0.7) {
				bgFade.alpha = 0.7;
			}

			if(bgFade.alpha >= 0.45) {
				dialogueStarted = true;
			}
		}, 5);
	}

	var dialogueStarted:Bool = false;
	var allowEnterKey:Bool = true;
	var getElapsed:Float = 0;
	override function update(elapsed:Float)
	{
		getElapsed += elapsed;
		if (!isEnding && dialogueMusic != null && dialogueMusic.volume < 0.7)
			dialogueMusic.volume += 0.02 * elapsed;


		super.update(elapsed);
	}

	override function destroy()
	{
		dialogueMusic.destroy();
	}
}