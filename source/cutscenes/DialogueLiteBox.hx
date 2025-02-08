package cutscenes;

import flixel.addons.text.FlxTypeText;
import objects.HealthIcon;

class DialogueLiteBox extends FlxSpriteGroup
{
	var curType:String = '';
	var curCharacter:String = '';
	var curAnim:String = '';

	var dialogueMusic:FlxSound;

	var dadAnimOffsets:Map<String, Array<Dynamic>> = [];
	var gfAnimOffsets:Map<String, Array<Dynamic>> = [];
	var bfAnimOffsets:Map<String, Array<Dynamic>> = [];

	var iconInfo:Array<Dynamic> = [];
	var portraitInfo:Array<Dynamic> = [];
	var dialogueList:Array<String> = [];

	var swagDialogue:FlxText;

	public var finishThing:Void->Void;

	var tablet:FlxSprite;
	var box:FlxSprite;
	var bgFade:FlxSprite;
	var icon:FlxSprite;

	var portraitLeft:FlxSprite;
	var portraitMiddle:FlxSprite;
	var portraitRight:FlxSprite;

	var addedPortraitsB:Array<Bool> = [false, false, false];
	var addedPortraitsT:Array<String> = ['', '', ''];

	public function new(?dialogueList:Array<String>)
	{
		super();

		this.dialogueList = dialogueList;

		dialogueMusic = new FlxSound();
		dialogueMusic.loadEmbedded(Paths.music('dialogues/${PlayState.SONG.song.toLowerCase().replace(" ", "-")}'), true, true);
		dialogueMusic.volume = 0;
		dialogueMusic.play();
		FlxG.sound.list.add(dialogueMusic);

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.4, function(tmr:FlxTimer)
		{
			bgFade.alpha += 0.15;
			if (bgFade.alpha > 0.7) {
				bgFade.alpha = 0.7;
				dialogueOpened = true;
			}
		}, 5);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;
	override function update(elapsed:Float)
	{
		if (dialogueMusic.volume < 0.5)
			dialogueMusic.volume += 0.01 * elapsed;

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if(dialogueStarted)
		{
			if(Controls.instance.ACCEPT)
			{
				if (dialogueList[1] == null && dialogueList[0] != null)
				{
					if (!isEnding)
					{
						isEnding = true;
						new FlxTimer().start(0.1, function(tmr:FlxTimer)
						{
							if(tablet != null) tablet.alpha -= 1 / 5;
							if(bgFade != null) bgFade.alpha -= 1 / 5 * 0.7;
							if(portraitLeft != null) portraitLeft.visible = false;
							if(portraitMiddle != null) portraitMiddle.visible = false;
							if(portraitRight != null) portraitRight.visible = false;
							if(swagDialogue != null) swagDialogue.alpha -= 1 / 5;
						}, 5);

						new FlxTimer().start(1.5, function(tmr:FlxTimer)
						{
							finishThing();
							kill();
						});
					}
				}
				else
				{
					dialogueList.remove(dialogueList[0]);
					startDialogue();
				}
			}
		}
		super.update(elapsed);
	}

	var isEnding:Bool = false;
	function startDialogue(txtToo:Bool = true):Void
	{
		refreshDialog(txtToo);
		refreshPortraitInfo();
		refreshStuff();
		FlxG.sound.play(Paths.sound('dialogue'), 1);

		trace(curType, curCharacter, curAnim, dialogueList[0]);
	}

	function refreshDialog(textToo:Bool = true):Void
	{
		var splitName:Array<String> = dialogueList[0].split("|");
		curType = splitName[0];
		curCharacter = splitName[1];
		curAnim = splitName[2];
		if(textToo) dialogueList[0] = splitName[3].trim();
	}

	function refreshPortraitInfo()
	{
		portraitInfo = CoolUtil.coolTextFile(Paths.getLitePath('images/dialogue/portraits/$curCharacter.txt'));
		iconInfo = CoolUtil.coolTextFile(Paths.getLitePath('images/dialogue/portraits/${curCharacter}icon.txt'));
	}

	function refreshStuff()
	{
		if(tablet != null) remove(tablet);
		if(box != null) remove(box);
		if(icon != null) remove(icon);
		if(swagDialogue != null) remove(swagDialogue);

		tablet = new FlxSprite();
		tablet.loadGraphic(Paths.image('dialogue/tablet'));
		tablet.updateHitbox();
		tablet.screenCenter(X);
		tablet.y = FlxG.height - tablet.height + 125;
		
		var portraitPosition:Array<Dynamic> = [];
		switch (curType)
		{
			case 'dad':
				if(addedPortraitsB[0] != true && addedPortraitsT[0] == '') {
					portraitLeft = new FlxSprite(230, 465);
					portraitLeft.frames = Paths.getSparrowAtlas('dialogue/portraits/$curCharacter');
					for(i in 0...portraitInfo.length) {
						var splitInfo:Array<Dynamic> = portraitInfo[0].split("|");
						if(i == 0 && splitInfo[5] != null) portraitPosition = [splitInfo[5][0], splitInfo[5][1]]; 
						portraitLeft.animation.addByPrefix(splitInfo[0], splitInfo[1], splitInfo[2], splitInfo[3]);
						dadAnimOffsets[splitInfo[0]] = [splitInfo[4][0], splitInfo[4][1]];
						portraitInfo.remove(portraitInfo[0]);
					}
					portraitLeft.updateHitbox();
					portraitLeft.setPosition(portraitPosition[0], portraitPosition[1]);
					add(portraitLeft);

					addedPortraitsT[0] = curCharacter;
					if(addedPortraitsB[0] == false) addedPortraitsB[0] = true;
				}
			case 'gf':
				if(addedPortraitsB[1] != true && addedPortraitsT[1] == '') {
					portraitMiddle = new FlxSprite(505, 480);
					portraitMiddle.frames = Paths.getSparrowAtlas('dialogue/portraits/$curCharacter');
					for(i in 0...portraitInfo.length) {
						var splitInfo:Array<Dynamic> = portraitInfo[0].split("|");
						if(i == 0 && splitInfo[5] != null) portraitPosition = [splitInfo[5][0], splitInfo[5][1]]; 
						portraitMiddle.animation.addByPrefix(splitInfo[0], splitInfo[1], splitInfo[2], splitInfo[3]);
						gfAnimOffsets[splitInfo[0]] = [splitInfo[4][0], splitInfo[4][1]];
						portraitInfo.remove(portraitInfo[0]);
					}
					portraitMiddle.updateHitbox();
					portraitMiddle.setPosition(portraitPosition[0], portraitPosition[1]);
					add(portraitMiddle);

					addedPortraitsT[1] = curCharacter;
					if(addedPortraitsB[1] == false) addedPortraitsB[1] = true;
				}
			case 'bf':
				if(addedPortraitsB[2] != true && addedPortraitsT[2] == '') {
					portraitRight = new FlxSprite(845, 490);
					portraitRight.frames = Paths.getSparrowAtlas('dialogue/portraits/$curCharacter');
					for(i in 0...portraitInfo.length) {
						var splitInfo:Array<Dynamic> = portraitInfo[0].split("|");
						if(i == 0 && splitInfo[5] != null) portraitPosition = [splitInfo[5][0], splitInfo[5][1]]; 
						portraitRight.animation.addByPrefix(splitInfo[0], splitInfo[1], splitInfo[2], splitInfo[3]);
						bfAnimOffsets[splitInfo[0]] = [splitInfo[4][0], splitInfo[4][1]];
						portraitInfo.remove(portraitInfo[0]);
					}
					portraitRight.updateHitbox();
					portraitRight.setPosition(portraitPosition[0], portraitPosition[1]);
					add(portraitRight);

					addedPortraitsT[2] = curCharacter;
					if(addedPortraitsB[2] == false) addedPortraitsB[2] = true;
				}
		}
		add(tablet);

		playPortraitAnim(curAnim);

		box = new FlxSprite();
		box.loadGraphic(Paths.image('dialogue/box'));
		box.updateHitbox();
		box.x = tablet.x + 75;
		box.y = tablet.y + 75;
		add(box);

		icon = new HealthIcon(curCharacter, (curType == 'bf'));
		//icon.scale.set(iconInfo[0].split("|")[0][0], iconInfo[0].split("|")[0][1]);
		icon.updateHitbox();
		icon.x = box.x + (curType == 'bf' ? (box.width - icon.width) : 0) + iconInfo[0].split("|")[1][0];
		icon.y = box.y + iconInfo[0].split("|")[1][1];
		add(icon);

		swagDialogue = new FlxText();
		swagDialogue.x = box.x + icon.width + 25;
		swagDialogue.y = box.y + 50;
		swagDialogue.fieldWidth = box.width - icon.width;
		swagDialogue.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.BLACK, (curType == 'bf' ? RIGHT : LEFT));
		swagDialogue.text = dialogueList[0];
		add(swagDialogue);
	}

	function playPortraitAnim(name:String)
	{
		switch(curType)
		{
			case 'dad':
				portraitLeft.animation.play(name);
				if (dadAnimOffsets.exists(name))
					portraitLeft.offset.set(dadAnimOffsets.get(name)[0], dadAnimOffsets.get(name)[1]);
			case 'gf':
				portraitMiddle.animation.play(name);
				if (gfAnimOffsets.exists(name))
					portraitMiddle.offset.set(gfAnimOffsets.get(name)[0], gfAnimOffsets.get(name)[1]);
			case 'bf':
				portraitRight.animation.play(name);
				if (bfAnimOffsets.exists(name))
					portraitRight.offset.set(bfAnimOffsets.get(name)[0], bfAnimOffsets.get(name)[1]);
		}
	}
}
