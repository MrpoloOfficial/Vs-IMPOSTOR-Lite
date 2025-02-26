function onCreate()
    makeLuaSprite("backgroundOfficeBroken", "bg/office/officeBroken", -1250, -1050)
    scaleObject("backgroundOfficeBroken", 1.8, 1.8)
    setProperty("backgroundOfficeBroken.antialiasing", false)
    setProperty("backgroundOfficeBroken.alpha", 0.000001)
    addLuaSprite("backgroundOfficeBroken")
end

function onStepHit()
	if curStep == 2080 then
		cameraShake('camGame', 0.02, 1.6);
		cameraShake('camHUD', 0.01, 1.6);
		setProperty('dad.alpha', 0.000001);
		setProperty('backgroundOffice.alpha', 0.000001);
		setProperty('backgroundOfficeBroken.alpha', 1);
	end
end