package cutscenes;

import flixel.addons.text.FlxTypeText;
import objects.HealthIcon;
import flixel.group.FlxGroup;

class DialogueLiteBox extends FlxSpriteGroup
{
	var curType:String = '';
	var curCharacter:String = '';
	var curCharacterNames:Array<String> = ['', '', ''];
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
	var defaultPortraitTypes:Array<String> = ['dad', 'gf', 'bf'];

	public function new(?dialogueList:Array<String>)
	{
		super();

		this.dialogueList = dialogueList;

		dialogueMusic = new FlxSound();
		dialogueMusic.loadEmbedded(Paths.music('dialogues/${PlayState.SONG.song.toLowerCase()}'), true, true);
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

		startDialogue(true);
	}

	var dialogueOpened:Bool = true;
	var dialogueStarted:Bool = false;
	var allowedEnterKey:Bool = true;
	var getElapsed:Float = 0;
	override function update(elapsed:Float)
	{
		if (!isEnding && dialogueMusic != null && dialogueMusic.volume < 0.7)
			dialogueMusic.volume += 0.02 * elapsed;

		getElapsed = elapsed; // why am i doing this? idk i just wanna sleep

		if (dialogueOpened && !dialogueStarted)
		{
			dialogueOpened = false;
		}

		if(dialogueStarted)
		{
			if(Controls.instance.ACCEPT && allowedEnterKey)
			{
				if (dialogueList[1] == null && dialogueList[0] != null)
				{
					if (!isEnding)
					{
						isEnding = true;
						// if(dialogueMusic != null) dialogueMusic.destroy();
						/*if(tabletGrp != null) {
							tabletGrp.clear();
							remove(tabletGrp);
						}
						if(boxArray != null) {
							for(box in boxArray) {
								box.visible = false;
							}
						}*/
						// FlxTween.tween(tablet, {y: FlxG.height + 200}, 0.6, {ease: FlxEase.cubeOut});

						FlxTween.cancelTweensOf(dialogueMusic);
						FlxTween.tween(dialogueMusic, {volume: 0}, 0.6, {ease: FlxEase.cubeOut, onComplete: function(_) {
							dialogueMusic.destroy();
						}});
						new FlxTimer().start(0.1, function(_)
						{
							//if(tablet != null) tablet.alpha -= 1 / 5;
							if(bgFade != null) bgFade.alpha -= 1 / 5 * 0.7;
						}, 5);

						FlxTween.tween(cameras[0], {"scroll.x": FlxG.height}, 0.6, {ease: FlxEase.cubeOut});

						new FlxTimer().start(0.6, function(_)
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

			if(curType != "" && (portraitLeft != null || portraitMiddle != null || portraitRight != null)) {
				alphaPortrait(curType);
			}
		}
		super.update(elapsed);
	}

	var isEnding:Bool = false;
	function startDialogue(firstTime:Bool = false):Void
	{
		refreshDialog();
		refreshPortraitInfo();
		refreshStuff(firstTime);
		FlxG.sound.play(Paths.sound('dialogue'), 1);
		// trace(curType, curCharacter, curAnim, dialogueList[0]);
	}

	function refreshDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split("|");
		curType = splitName[0];
		curCharacter = splitName[1];
		curAnim = splitName[2];
		dialogueList[0] = splitName[3].trim();
	}

	function refreshPortraitInfo()
	{
		portraitInfo = CoolUtil.coolTextFile(Paths.getLitePath('images/dialogue/portraits/$curCharacter/$curCharacter.txt'));
		iconInfo = CoolUtil.coolTextFile(Paths.getLitePath('images/dialogue/portraits/$curCharacter/${curCharacter}icon.txt'));
	}

	var tweenBox:FlxTween;
	var boxArray:Array<FlxSprite> = [];
	function refreshStuff(firstTime:Bool = false)
	{
		if(firstTime) {
			tablet = new FlxSprite();
			tablet.loadGraphic(Paths.image('dialogue/tablets/${curCharacter}tablet'));
			tablet.updateHitbox();
			tablet.screenCenter(X);
			tablet.y = FlxG.height + 200;
			tablet.antialiasing = false;
			add(tablet);

			FlxTween.tween(tablet, {y: FlxG.height - tablet.height + 125}, 0.6, {ease: FlxEase.quadOut, 
				onComplete: function (_) {
					allowedEnterKey = true;
					refreshStuff();
				}
			});
		} else {
			//if(tablet != null) remove(tablet);
			if(tabletGrp != null) {
				if(tweenBox != null) tweenBox.cancel(); 
				tweenBox = FlxTween.tween(tabletGrp, {y: tabletGrp.y + 120}, 0.000000001);
			}

			//tablet = new FlxSprite();
			tablet.loadGraphic(Paths.image('dialogue/tablets/${curCharacter}tablet'));
			tablet.updateHitbox();
			tablet.screenCenter(X);
			tablet.y = FlxG.height - tablet.height + 125;
			tablet.antialiasing = false;
			//add(tablet);
			
			var portraitPosition:Array<Dynamic> = [];
			switch (curType)
			{
				case 'dad':
					if(addedPortraitsB[0] != true && addedPortraitsT[0] != curCharacter) {
						if(portraitLeft != null) remove(portraitLeft);
						portraitLeft = new FlxSprite(230, 465);
						portraitLeft.frames = Paths.getSparrowAtlas('dialogue/portraits/$curCharacter/$curCharacter');
						for(i in 0...portraitInfo.length) {
							if(i > 0) {
								var splitInfo:Array<Dynamic> = portraitInfo[0].split("|");
								if(i == 1) portraitPosition = [splitInfo[6], splitInfo[7]]; 
								portraitLeft.animation.addByPrefix(splitInfo[0], splitInfo[1], splitInfo[2], splitInfo[3]);
								dadAnimOffsets[splitInfo[0]] = [splitInfo[4], splitInfo[5]];
							} else curCharacterNames[0] = portraitInfo[0];
							portraitInfo.remove(portraitInfo[0]);
						}
						portraitLeft.updateHitbox();
						portraitLeft.antialiasing = false;
						portraitLeft.setPosition(portraitPosition[0], portraitPosition[1]);
						insert(members.indexOf(tablet), portraitLeft);

						portraitLeft.alpha = 0.00001;
						portraitLeft.y = portraitLeft.y + portraitLeft.height;
						FlxTween.tween(portraitLeft, {y: portraitPosition[1], alpha: 1}, 0.6, {ease: FlxEase.quadOut});

						addedPortraitsT[0] = curCharacter;
						//if(addedPortraitsB[0] == false) addedPortraitsB[0] = true;
					}
				case 'gf':
					if(addedPortraitsB[1] != true && addedPortraitsT[1] != curCharacter) {
						if(portraitMiddle != null) remove(portraitMiddle);
						portraitMiddle = new FlxSprite(505, 480);
						portraitMiddle.frames = Paths.getSparrowAtlas('dialogue/portraits/$curCharacter/$curCharacter');
						for(i in 0...portraitInfo.length) {
							if(i > 0) {
								var splitInfo:Array<Dynamic> = portraitInfo[0].split("|");
								if(i == 1) portraitPosition = [splitInfo[6], splitInfo[7]]; 
								portraitMiddle.animation.addByPrefix(splitInfo[0], splitInfo[1], splitInfo[2], splitInfo[3]);
								gfAnimOffsets[splitInfo[0]] = [splitInfo[4], splitInfo[5]];
							} else curCharacterNames[1] = portraitInfo[0];
							portraitInfo.remove(portraitInfo[0]);
						}
						portraitMiddle.updateHitbox();
						portraitMiddle.antialiasing = false;
						portraitMiddle.setPosition(portraitPosition[0], portraitPosition[1]);
						insert(members.indexOf(tablet), portraitMiddle);

						portraitMiddle.alpha = 0.00001;
						portraitMiddle.y = portraitMiddle.y + portraitMiddle.height;
						FlxTween.tween(portraitMiddle, {y: portraitPosition[1], alpha: 1}, 0.6, {ease: FlxEase.quadOut});

						addedPortraitsT[1] = curCharacter;
						//if(addedPortraitsB[1] == false) addedPortraitsB[1] = true;
					}
				case 'bf':
					if(addedPortraitsB[2] != true && addedPortraitsT[2] != curCharacter) {
						if(portraitRight != null) remove(portraitRight);
						portraitRight = new FlxSprite(845, 490);
						portraitRight.frames = Paths.getSparrowAtlas('dialogue/portraits/$curCharacter/$curCharacter');
						for(i in 0...portraitInfo.length) {
							if(i > 0) {
								var splitInfo:Array<Dynamic> = portraitInfo[0].split("|");
								if(i == 1) portraitPosition = [splitInfo[6], splitInfo[7]]; 
								portraitRight.animation.addByPrefix(splitInfo[0], splitInfo[1], splitInfo[2], splitInfo[3]);
								bfAnimOffsets[splitInfo[0]] = [splitInfo[4], splitInfo[5]];
							} else curCharacterNames[2] = portraitInfo[0];
							portraitInfo.remove(portraitInfo[0]);
						}
						portraitRight.updateHitbox();
						portraitRight.antialiasing = false;
						portraitRight.setPosition(portraitPosition[0], portraitPosition[1]);
						insert(members.indexOf(tablet), portraitRight);

						portraitRight.alpha = 0.00001;
						portraitRight.y = portraitRight.y + portraitRight.height;
						FlxTween.tween(portraitRight, {y: portraitPosition[1], alpha: 1}, 0.6, {ease: FlxEase.quadOut});

						addedPortraitsT[2] = curCharacter;
						//if(addedPortraitsB[2] == false) addedPortraitsB[2] = true;
					}
			}

			tabletGrp = new FlxSpriteGroup();
			add(tabletGrp);

			playPortraitAnim(curAnim);

			box = new FlxSprite();
			box.loadGraphic(Paths.image('dialogue/box'));
			box.updateHitbox();
			box.antialiasing = false;
			box.x = tablet.x + 75;
			box.y = tablet.y + 75;
			tabletGrp.add(box);
			boxArray.push(box);

			iconSplitInfo = iconInfo[0].split("|");

			icon = new HealthIcon(curCharacter, (curType == 'bf'));
			icon.scale.set(iconSplitInfo[0], iconSplitInfo[1]);
			icon.updateHitbox();
			icon.antialiasing = false;
			icon.x = box.x + (curType == 'bf' ? (box.width - icon.width) : 0) + iconSplitInfo[2];
			icon.y = box.y + iconSplitInfo[3];
			tabletGrp.add(icon);
			boxArray.push(icon);

			dialogueName = new FlxText();
			dialogueName.fieldWidth = box.width - icon.width;
			dialogueName.setFormat(Paths.font("vcr.ttf"), 26, FlxColor.BLACK, (curType == 'bf' ? RIGHT : LEFT));
			dialogueName.x = box.x + 115 - (curType == 'bf' ? 125 : 0);
			dialogueName.y = box.y + 5;
			dialogueName.text = curCharacterNames[defaultPortraitTypes.indexOf(curType)];
			tabletGrp.add(dialogueName);
			boxArray.push(dialogueName);

			swagDialogue = new FlxText();
			swagDialogue.fieldWidth = box.width - icon.width - 25;
			swagDialogue.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.BLACK, (curType == 'bf' ? RIGHT : LEFT));
			swagDialogue.x = box.x + 115 - (curType == 'bf' ? 100 : 0);
			swagDialogue.y = box.y + 40;
			swagDialogue.text = dialogueList[0];
			tabletGrp.add(swagDialogue);
			boxArray.push(swagDialogue);
		}
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

	var twnMoveY:FlxTween;
	function alphaPortrait(except:String)
	{
		switch(except)
		{
			case 'dad':
				if(portraitRight != null) portraitRight.alpha = FlxMath.lerp(portraitRight.alpha, 0.6, FlxMath.bound(getElapsed * 14, 0, 1));
				if(portraitMiddle != null) portraitMiddle.alpha = FlxMath.lerp(portraitMiddle.alpha, 0.6, FlxMath.bound(getElapsed * 14, 0, 1));
				if(portraitLeft != null) portraitLeft.alpha = FlxMath.lerp(portraitLeft.alpha, 1, FlxMath.bound(getElapsed * 14, 0, 1));
			case 'gf':
				if(portraitRight != null) portraitRight.alpha = FlxMath.lerp(portraitRight.alpha, 0.6, FlxMath.bound(getElapsed * 14, 0, 1));
				if(portraitLeft != null) portraitLeft.alpha = FlxMath.lerp(portraitLeft.alpha, 0.6, FlxMath.bound(getElapsed * 14, 0, 1));
				if(portraitMiddle != null) portraitMiddle.alpha = FlxMath.lerp(portraitMiddle.alpha, 1, FlxMath.bound(getElapsed * 14, 0, 1));
			case 'bf':
				if(portraitMiddle != null) portraitMiddle.alpha = FlxMath.lerp(portraitMiddle.alpha, 0.6, FlxMath.bound(getElapsed * 14, 0, 1));
				if(portraitLeft != null) portraitLeft.alpha = FlxMath.lerp(portraitLeft.alpha, 0.6, FlxMath.bound(getElapsed * 14, 0, 1));
				if(portraitRight != null) portraitRight.alpha = FlxMath.lerp(portraitRight.alpha, 1, FlxMath.bound(getElapsed * 14, 0, 1));
		}
	}

	override function destroy()
	{
		dialogueMusic.destroy();
	}
}