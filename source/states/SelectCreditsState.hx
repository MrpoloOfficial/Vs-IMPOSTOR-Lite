package states;

import flixel.effects.FlxFlicker;

class SelectCreditsState extends MusicBeatState
{
    public static var prevCurCredit:Int = 0;
    public static var curCredit:Int = 0;

    public var logosGrp:FlxTypedGroup<FlxSprite>;

    public var teamsList:Array<Array<Dynamic>> = [ // Team Name - Position Add[X/Y] - Scale[X/Y] - Devs
        ["lite", [-300, 0], [0.75, 0.75], [
                ['choma',			'Description 1 here',			'',		'FFFFFF'],
                ['bpforest',		'Description 2 here',			'',		'FFFFFF'],
                ['gamemon',		    'Description 3 here',			'',		'FFFFFF'],
                ['mayagi',		    'Description 4 here',			'',		'FFFFFF'],
                ['ratang',			'Description 5 here',			'',		'FFFFFF'],
                ['atin',			'Description 6 here',			'',		'FFFFFF']
            ]
        ],
        ["liteImp", [300, 0], [0.4, 0.4], [
                ['upqgg',			'Description 1 here',			'',		'FFFFFF'],
                ['gtm',				'Description 2 here',			'',		'FFFFFF'],
                ['CaptainLite',		'Description 3 here',			'',		'FFFFFF'],
                ['JustAGuy',		'Description 4 here',			'',		'FFFFFF'],
                ['Mrpolo',			'hi i coded the ENTIRE mod, i hope you enjoy\'ed it :D',			'',		'FFFFFF'],
                ['Red',		        "hi i'm a Red Impostor, i've coded this mod a bit, and i'm happy to participate in it.",			'',		'FFFFFF']
            ]
        ]
    ];

    override function create()
    {
        #if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Choosing a team...", null);
		#end

		persistentUpdate = persistentDraw = true;
        FlxG.mouse.visible = true;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('storymode/bg'));
		bg.antialiasing = false;
        bg.screenCenter();
		add(bg);

        logosGrp = new FlxTypedGroup<FlxSprite>();
		add(logosGrp);

        for(i in 0...teamsList.length)
        {
            var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('credits/${teamsList[i][0]}'));
            logo.antialiasing = false;
            logo.scale.set(teamsList[i][2][0], teamsList[i][2][1]);
            logo.updateHitbox();
            logo.screenCenter();
            logo.x += teamsList[i][1][0];
            logo.y += teamsList[i][1][1];
            logo.ID = i;
            logosGrp.add(logo);
        }

        super.create();
    }

    var selected:Bool = false;
    override function update(elapsed:Float)
    {
        if(!selected)
        {
            logosGrp.forEach(function(spr:FlxSprite) {
                if(FlxG.mouse.overlaps(spr)) {
                    prevCurCredit = curCredit;
                    curCredit = spr.ID;
                    if(prevCurCredit != curCredit) {
                        FlxG.sound.play(Paths.sound('scrollMenu'));
                    }
                    if(FlxG.mouse.justPressed) {
                        enterCredits();
                    }
                }
            });

            if (controls.UI_LEFT_P)
				changeItem(-1);
			if (controls.UI_RIGHT_P)
				changeItem(1);

            logosGrp.forEach(function(spr:FlxSprite) 
            {
                if(spr.ID == curCredit) {
                    spr.scale.x = FlxMath.lerp(spr.scale.x, teamsList[curCredit][2][0] + 0.1, FlxMath.bound(elapsed * 12, 0, 1));
                    spr.scale.y = FlxMath.lerp(spr.scale.y, teamsList[curCredit][2][1] + 0.1, FlxMath.bound(elapsed * 12, 0, 1));
                    spr.alpha = FlxMath.lerp(spr.alpha, 1, FlxMath.bound(elapsed * 10, 0, 1));
                }
                else {
                    spr.scale.x = FlxMath.lerp(spr.scale.x, teamsList[spr.ID][2][0], FlxMath.bound(elapsed * 12, 0, 1));
                    spr.scale.y = FlxMath.lerp(spr.scale.y, teamsList[spr.ID][2][1], FlxMath.bound(elapsed * 12, 0, 1));
                    spr.alpha = FlxMath.lerp(spr.alpha, 0.8, FlxMath.bound(elapsed * 10, 0, 1));
                }
            });

            if (controls.ACCEPT)
                enterCredits();
            
            if (controls.BACK)
            {
                FlxG.mouse.visible = false;
                FlxG.sound.play(Paths.sound('cancelMenu'));
                FlxG.switchState(() -> new MainMenuState());
                selected = true;
            }
        }

        super.update(elapsed);
    }    

    function enterCredits()
    {
        FlxG.sound.play(Paths.sound('confirmMenu'));
        selected = true;
        FlxG.mouse.visible = false;
        FlxFlicker.flicker(logosGrp.members[curCredit], 1, 0.06, false, false, function(flick:FlxFlicker)
        {
            CreditsState.teamName = teamsList[curCredit][0];
            CreditsState.defaultList = teamsList[curCredit][3];
            FlxG.switchState(() -> new CreditsState());
        });
    }

    function changeItem(huh:Int = 0)
    {
        if(huh != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
        prevCurCredit = curCredit;
        curCredit += huh;
        if (curCredit >= teamsList.length)
            curCredit = 0;
        if (curCredit < 0)
            curCredit = teamsList.length - 1;
    }
}