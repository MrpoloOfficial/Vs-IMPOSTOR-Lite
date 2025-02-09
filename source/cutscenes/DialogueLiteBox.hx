package cutscenes;

import flixel.addons.text.FlxTypeText;
import objects.HealthIcon;
import flixel.group.FlxGroup;

class DialogueLiteBox extends FlxSpriteGroup
{
	var curType:String = '';
	var curCharacter:String = '';
	var curAnim:String = '';

	var dialogueMusic:FlxSound;

	var dadAnimOffsets:Map<String, Array<Dynamic>> = [];
	var gfAnimOffsets:Map<String, Array<Dynamic>> = [];
	var bfAnimOffsets:Map<String, Array<Dynamic>> = [];

	var iconSplitInfo:Array<Dynamic> = [];
	var iconInfo:Array<Dynamic> = [];
	var portraitInfo:Array<Dynamic> = [];
	var dialogueList:Array<String> = [];

	var swagDialogue:FlxText;
	var dialogueName:FlxText;

	public var finishThing:Void->Void;

	var tabletGrp:FlxSpriteGroup;

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
		dialogueMusic.loadEmbedded(Paths.music('dialogues/${PlayState.SONG.song.toLowerCase()}'), true, true);
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
		if (dialogueMusic.volume < 0.7)
			dialogueMusic.volume += 0.01 * elapsed;

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if(dialogueStarted)
		{
			if(tablet != null && box != null && tweenBox == null) {
				box.x = tablet.x + 75;
				box.y = tablet.y + 75;
			}

			if(icon != null && box != null) {
				icon.x = box.x + (curType == 'bf' ? (box.width - icon.width) : 0) + iconSplitInfo[2];
				icon.y = box.y + iconSplitInfo[3];
			}

			if(dialogueName != null && box != null && icon != null) {
				dialogueName.x = box.x + icon.width - 10;
				dialogueName.y = box.y + 5;
				dialogueName.fieldWidth = box.width - icon.width;
			}

			if(swagDialogue != null && box != null && icon != null) {
				swagDialogue.x = box.x + icon.width - 10;
				swagDialogue.y = box.y + 40;
				swagDialogue.fieldWidth = box.width - icon.width - 25;
			}

			if(Controls.instance.ACCEPT)
			{
				if (dialogueList[1] == null && dialogueList[0] != null)
				{
					if (!isEnding)
					{
						isEnding = true;
						dialogueMusic.destroy();
						new FlxTimer().start(0.1, function(tmr:FlxTimer)
						{
							if(tablet != null) tablet.alpha -= 1 / 5;
							if(bgFade != null) bgFade.alpha -= 1 / 5 * 0.7;
							if(portraitLeft != null) portraitLeft.visible = false;
							if(portraitMiddle != null) portraitMiddle.visible = false;
							if(portraitRight != null) portraitRight.visible = false;
							if(swagDialogue != null) swagDialogue.alpha -= 1 / 5;
							if(dialogueName != null) dialogueName.alpha -= 1 / 5;
							if(box != null) box.alpha -= 1 / 5;
							if(icon != null) icon.alpha -= 1 / 5;
						}, 5);

						new FlxTimer().start(0.6, function(tmr:FlxTimer)
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

	var tweenBox:FlxTween;
	function refreshStuff()
	{
		//if(tablet != null) remove(tablet);
		/*if(box != null) box.y += 125;
		if(icon != null) icon.y += 125;
		if(swagDialogue != null) swagDialogue.y += 125;
		if(dialogueName != null) dialogueName.y += 125;*/
		if(box != null) {
			if(tweenBox != null) tweenBox.cancel(); 
			tweenBox = FlxTween.tween(box, {y: box.y + 100}, 0.7, {ease: FlxEase.quadOut});
		}

		tabletGrp = new FlxSpriteGroup();
		add(tabletGrp);

		tablet = new FlxSprite();
		tablet.loadGraphic(Paths.image('dialogue/tablets/${curCharacter}tablet'));
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
						if(i == 0) portraitPosition = [splitInfo[6], splitInfo[7]]; 
						portraitLeft.animation.addByPrefix(splitInfo[0], splitInfo[1], splitInfo[2], splitInfo[3]);
						dadAnimOffsets[splitInfo[0]] = [splitInfo[4], splitInfo[5]];
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
						if(i == 0) portraitPosition = [splitInfo[6], splitInfo[7]]; 
						portraitMiddle.animation.addByPrefix(splitInfo[0], splitInfo[1], splitInfo[2], splitInfo[3]);
						gfAnimOffsets[splitInfo[0]] = [splitInfo[4], splitInfo[5]];
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
						if(i == 0) portraitPosition = [splitInfo[6], splitInfo[7]]; 
						portraitRight.animation.addByPrefix(splitInfo[0], splitInfo[1], splitInfo[2], splitInfo[3]);
						bfAnimOffsets[splitInfo[0]] = [splitInfo[4], splitInfo[5]];
						portraitInfo.remove(portraitInfo[0]);
					}
					portraitRight.updateHitbox();
					portraitRight.setPosition(portraitPosition[0], portraitPosition[1]);
					add(portraitRight);

					addedPortraitsT[2] = curCharacter;
					if(addedPortraitsB[2] == false) addedPortraitsB[2] = true;
				}
		}
		tabletGrp.add(tablet);

		playPortraitAnim(curAnim);

		box = new FlxSprite();
		box.loadGraphic(Paths.image('dialogue/box'));
		box.updateHitbox();
		box.x = tablet.x + 75;
		box.y = tablet.y + 75;
		tabletGrp.add(box);

		iconSplitInfo = iconInfo[0].split("|");

		icon = new HealthIcon(curCharacter, (curType == 'bf'));
		icon.scale.set(iconSplitInfo[0], iconSplitInfo[1]);
		icon.updateHitbox();
		icon.x = box.x + (curType == 'bf' ? (box.width - icon.width) : 0) + iconSplitInfo[2];
		icon.y = box.y + iconSplitInfo[3];
		tabletGrp.add(icon);

		dialogueName = new FlxText();
		dialogueName.x = box.x + icon.width - 10;
		dialogueName.y = box.y + 5;
		dialogueName.fieldWidth = box.width - icon.width;
		dialogueName.setFormat(Paths.font("vcr.ttf"), 26, FlxColor.BLACK, (curType == 'bf' ? RIGHT : LEFT));
		dialogueName.text = curCharacter.charAt(0).toUpperCase() + curCharacter.substr(1).toLowerCase();
		tabletGrp.add(dialogueName);

		swagDialogue = new FlxText();
		swagDialogue.x = box.x + icon.width - 10;
		swagDialogue.y = box.y + 40;
		swagDialogue.fieldWidth = box.width - icon.width - 25;
		swagDialogue.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.BLACK, (curType == 'bf' ? RIGHT : LEFT));
		swagDialogue.text = dialogueList[0];
		tabletGrp.add(swagDialogue);
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

	override function destroy()
	{
		dialogueMusic.destroy();
	}
}
