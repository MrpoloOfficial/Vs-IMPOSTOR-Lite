local isSongSM = false;

function onCreatePost()
    	if songName == 'sussus-moongus' then isSongSM = true; end
    	if isSongSM then
    		setProperty('defaultCamZoom', 0.65);
    		setProperty('camGame.zoom', 0.65);
    		setProperty('camHUD.alpha', 0.00001);
    		runHaxeCode([[
			import flixel.addons.display.FlxBackdrop;
			var spaceInf:FlxBackdrop = new FlxBackdrop(Paths.image("bg/polus/stars"));
			spaceInf.setPosition(-1460, -1200);
			spaceInf.scale.set(2.2, 2.2);
			// spaceInf.scrollFactor.set(0.8, 0.8);
			addBehindGF(spaceInf);
    		]]);
    	end

    	makeLuaSprite("pbg", "bg/polus/background", -1460, -1200)
    	scaleObject("pbg", 2.2, 2.2)
    	setProperty("pbg.antialiasing", false)
    	addLuaSprite("pbg")

    	makeLuaSprite("moon", "bg/polus/moon", -1750, -2500)
    	scaleObject("moon", 2.2, 2.2)
    	setProperty("moon.antialiasing", false)
    	addLuaSprite("moon")

    	makeLuaSprite("pbgC", "bg/polus/fellas", -1460, -1200)
    	scaleObject("pbgC", 2.2, 2.2)
    	setProperty("pbgC.antialiasing", false)
    	if songName == 'meltdown' then addLuaSprite("pbgC") end

    	makeLuaSprite('whiteThing', '', 0, 0);
    	makeGraphic('whiteThing', 2000, 2000, 'FFFFFF')
    	if isSongSM then addLuaSprite('whiteThing', false); end
    	setProperty('whiteThing.alpha', 1)
    	setObjectCamera('whiteThing', 'camOther');

	if isSongSM then
		setProperty('isCameraOnForcedPos', true);
		setProperty('freezeCamera', true);
	end
end

function onSongStart()
	if isSongSM then
		doTweenAlpha('tweenAlpha', 'whiteThing', 0, 11);
		doTweenZoom('tweenZoom', 'camGame', 0.5, 10.5, 'quadInOut');
		setProperty('camGame.scroll.x', -500);
		setProperty('camGame.scroll.y', -2000);
	end
end

function onStepHit()
	if isSongSM and curStep == 2 then
		doTweenY('tweenY', 'camGame.scroll', 0, 11, 'quadInOut');
	elseif isSongSM and curStep == 112 then
		doTweenAlpha('tweenAlpha', 'camHUD', 1, 1);
	elseif isSongSM and curStep == 128 then
		cancelTween('tweenY');
		setProperty('isCameraOnForcedPos', false);
		setProperty('freezeCamera', false);
		setProperty('defaultCamZoom', 0.6);
	end
end

function onTweenCompleted(t)
	if t == 'tweenZoom' then
		setProperty('defaultCamZoom', getProperty('camGame.zoom'));
	end
end