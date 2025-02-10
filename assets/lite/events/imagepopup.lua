function onEvent(name, value1, value2)
	if name == "imagepopup" then
		makeLuaSprite('image', value1, 0, 0);
		addLuaSprite('image', true);
		doTweenColor('hello', 'image', 'FFFFFFFF', 0.5, 'quartIn');
                setScrollFactor('image', 0.2, 0.5) --you can customize those numbers on the left for the x and y values you would like
		runTimer('wait', value2);
	end
end

function onTimerCompleted(tag, loops, loopsleft)
	if tag == 'wait' then
		doTweenAlpha('byebye', 'image', 0, 0.3, 'linear');
	end
end

function onTweenCompleted(tag)
	if tag == 'byebye' then
		removeLuaSprite('image', true);
	end
end