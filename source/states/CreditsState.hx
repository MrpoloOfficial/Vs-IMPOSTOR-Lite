package states;

import objects.AttachedSprite;
import objects.MenuItem;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<MenuItem>;
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:FlxColor;
	var colorTween:FlxTween;
	var descBox:AttachedSprite;

	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var offsetThing:Float = -75;

	public var onST:Bool = false;
	public var specialSection:SpecialThanks;

	public static var teamName:String = "";

	public static var defaultList:Array<Array<String>> = [];

	override function create()
	{
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Looking at the credits", null);
		#end

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('sketch2'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();
		
		grpOptions = new FlxTypedGroup<MenuItem>();
		add(grpOptions);

		#if MODS_ALLOWED
		for (mod in Mods.parseList().enabled) pushModCreditsToList(mod);
		#end
		
		for(i in defaultList) {
			creditsStuff.push(i);
		}
	
		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:MenuItem = new MenuItem(0, 0);
			optionText.loadGraphic(Paths.image('credits/${teamName}/' + creditsStuff[i][0]));
			optionText.x += ((optionText.width) * i);
			optionText.targetX = i;
			optionText.antialiasing = ClientPrefs.data.antialiasing;
			grpOptions.add(optionText);
			optionText.visible = (creditsStuff[i][0] != "SpecialThanks");

			if(isSelectable) {
				if(creditsStuff[i][4] != null)
				{
					Mods.currentModDirectory = creditsStuff[i][4];
				}
				Mods.currentModDirectory = '';

				if(curSelected == -1) curSelected = i;
			}
		}

		if(teamName == "liteImp")
		{
			specialSection = new SpecialThanks();
			specialSection.sprAttacher = grpOptions.members[grpOptions.members.length-1];
			specialSection.stateGet = this;
			add(specialSection);
		}

		leftArrow = new FlxSprite(20, 0);
		leftArrow.antialiasing = false;
		leftArrow.loadGraphic(Paths.image('arrowButton'));
		leftArrow.color = FlxColor.WHITE;
		leftArrow.screenCenter(Y);

		rightArrow = new FlxSprite();
		rightArrow.antialiasing = false;
		rightArrow.loadGraphic(Paths.image('arrowButton'));
		rightArrow.color = FlxColor.WHITE;
		rightArrow.screenCenter(Y);
		rightArrow.x = FlxG.width - rightArrow.width - 20;
		rightArrow.flipX = true;
		add(leftArrow);
		add(rightArrow);
		
		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1100, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER/*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		descText.scrollFactor.set();
		//descText.borderSize = 2.4;
		descBox.sprTracker = descText;
		add(descText);

		var socialCheck:FlxText = new FlxText(0, FlxG.height - 24, 0, "Press ACCEPT to move to social media!", 12);
		socialCheck.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		socialCheck.screenCenter(X);
		add(socialCheck);

		bg.color = CoolUtil.colorFromString(creditsStuff[curSelected][0] == "SpecialThanks" ? "FFFFFF" : creditsStuff[curSelected][3]);
		intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (controls.UI_RIGHT)
			rightArrow.color = FlxColor.GRAY;
		else
			rightArrow.color = FlxColor.WHITE;

		if (controls.UI_LEFT)
			leftArrow.color = FlxColor.GRAY;
		else
			leftArrow.color = FlxColor.WHITE;

		if(!quitting)
		{
			if(creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

				var leftP = controls.UI_LEFT_P;
				var rightP = controls.UI_RIGHT_P;

				if (leftP)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (rightP)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if(rightP || leftP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (leftP ? -shiftMult : shiftMult));
					}
				}
			}

			if(creditsStuff[curSelected][0] != "SpecialThanks" && controls.ACCEPT && (creditsStuff[curSelected][2] == null || creditsStuff[curSelected][2].length > 4)) {
				CoolUtil.browserLoad(creditsStuff[curSelected][2]);
			}
			if (controls.BACK)
			{
				if(colorTween != null) {
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(() -> new SelectCreditsState());
				quitting = true;
			}
		}
		super.update(elapsed);
	}

	var moveTween:FlxTween = null;
	public function changeSelection(change:Int = 0, manualText:String = "")
	{
		if(manualText == "") FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var newColor:FlxColor = CoolUtil.colorFromString(creditsStuff[curSelected][0] == "SpecialThanks" ? "FFFFFF" : creditsStuff[curSelected][3]);
		//trace('The BG color is: $newColor');
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		for (i => item in grpOptions.members)
			item.targetX = i - curSelected;

		onST = (creditsStuff[curSelected][0] == "SpecialThanks");

		var isEmpty = (creditsStuff[curSelected][1] == "");
		descText.visible = !isEmpty;
		descBox.visible = !isEmpty;

		descText.text = (manualText != "" ? manualText : creditsStuff[curSelected][1]);
		if(change != 0 && onST) {
			if(specialSection != null) descText.text = specialSection.groupList[specialSection.currentPerson][1];
		}

		descText.y = FlxG.height - descText.height + offsetThing - 60;

		if(moveTween != null) moveTween.cancel();
		moveTween = FlxTween.tween(descText, {y : descText.y + 75}, 0.25, {ease: FlxEase.sineOut});

		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
	}

	#if MODS_ALLOWED
	function pushModCreditsToList(folder:String)
	{
		var creditsFile:String = null;
		if(folder != null && folder.trim().length > 0) creditsFile = Paths.mods(folder + '/data/credits.txt');
		else creditsFile = Paths.mods('data/credits.txt');

		if (FileSystem.exists(creditsFile))
		{
			var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
			for(i in firstarray)
			{
				var arr:Array<String> = i.replace('\\n', '\n').split("::");
				if(arr.length >= 5) arr.push(folder);
				creditsStuff.push(arr);
			}
			creditsStuff.push(['']);
		}
	}
	#end

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}

class SpecialThanks extends FlxTypedSpriteGroup<FlxSprite>
{
	public var currentPerson:Int = 0;

	public var sprAttacher:FlxSprite;
	public var stateGet:CreditsState;
	public var blackBox:FlxSprite;

	public var peopleGrp:FlxTypedSpriteGroup<Alphabet> = new FlxTypedSpriteGroup();

	public var groupList:Array<Dynamic> = tjson.TJSON.parse(File.getContent(Paths.getLitePath("data/credits.json"))).specialthanks;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		blackBox = new FlxSprite();
		blackBox.makeGraphic(1, 1, FlxColor.BLACK);
		blackBox.alpha = 0.6;
		add(blackBox);

		add(peopleGrp);

		for(i => person in groupList) {
			var nameSpr:Alphabet = new Alphabet(0, 0, person[0], true);
			nameSpr.distancePerItem.x = 0;
			nameSpr.targetY = i;
			nameSpr.ID = i;
			nameSpr.setScale(0.75, 0.75);
			nameSpr.screenCenter();
			nameSpr.y += blackBox.y + (90 * (i - (groupList.length / 2)));
			peopleGrp.add(nameSpr);
		}

		blackBox.scale.set(peopleGrp.width + 100, peopleGrp.height + 100);
		blackBox.updateHitbox();
		blackBox.screenCenter();
		blackBox.y -= 50;

		for(i => nameSpr in peopleGrp.members) {
			nameSpr.screenCenter();
			nameSpr.y += blackBox.y + (90 * (i - (groupList.length / 2))) - 55;
		}
		// peopleGrp.y += 25;

		changePerson();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	
		this.x = sprAttacher.x + sprAttacher.width;
		this.y = sprAttacher.y;

		if(stateGet != null && stateGet.onST) {
			if(FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W) changePerson(-1);
			if(FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S) changePerson(1);

			if(FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) {
				if(groupList[currentPerson][2] != "" && groupList[currentPerson][2] != null) CoolUtil.browserLoad(groupList[currentPerson][2]);
			}
		}
	}

	function changePerson(change:Int = 0)
	{
		if(change != 0) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		currentPerson += change;
		if (currentPerson < 0)
			currentPerson = peopleGrp.length - 1;
		if (currentPerson >= peopleGrp.length)
			currentPerson = 0;

		for(i => person in peopleGrp.members) {
			person.targetY = i - currentPerson;

			if(person.ID == currentPerson) 
				person.alpha = 1; 
			else person.alpha = 0.5;
		}

		if(stateGet != null) {
			stateGet.changeSelection(0, groupList[currentPerson][1]);
		} 
	}
}