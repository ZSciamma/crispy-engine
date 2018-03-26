local state = {}

local nextB = sButton("Next", 500, 500, 100, 50, "summary", "menu")

function state:new()
	return lovelyMoon.new(self)
end


function state:load()
end


function state:close()
end


function state:enable()
	local newLevel = CalculateLevel()
	if newLevel > studentInfo.level then
		addAlert("Congratulations! You moved up to level "..newLevel.."!", 500, 500)
	elseif newLevel < studentInfo.level then
		local move = CheckLevelDecrease(studentInfo.level)
		if move then studentInfo.level = newLevel end
		addAlert("Oh no! You moved down to level "..studentInfo.level..". Hone your skills to move back up!", 500, 500)
	end
end


function state:disable()
end


function state:update(dt)
end


function state:draw()
	nextB:draw()
end

function state:keypressed(key, unicode)

end

function state:keyreleased(key, unicode)

end

function state:mousepressed(x, y, button)
	nextB:mousepressed(x, y)
end

function state:mousereleased(x, y, button)
	nextB:mousereleased(x, y)
end

function CheckLevelDecrease(higerLevel)		-- Checks whether the user's current level should be decreased
    return studentInfo.ratingSum < levels[higherLevel][3] - 4		-- User is allowed to have a total rating sum 4 lower than that needed to move up a level; below this, the level will decrease
end


return state
