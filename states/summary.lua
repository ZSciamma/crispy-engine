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
		studentInfo.level = newLevel
		IncreaseLevel(newLevel)
	elseif newLevel < studentInfo.level then
		local move = CheckLevelDecrease(studentInfo.level)
		if move then
			studentInfo.level = newLevel
			addAlert("Oh no! You moved down to level "..studentInfo.level..". Hone your skills to move back up!", 500, 500)
			DecreaseLevel(newLevel)
		end
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

function CheckLevelDecrease(higherLevel)		-- Checks whether the user's current level should be decreased
	--[[
	local currentRatings = {}
	local level = 0
	local currentTotal = 0
	for i,l in ipairs(level) do
		for j,interval in ipairs(l[1]) do
			currentRatings[interval] = 1
		end
		for
	--]]
    return studentInfo.ratingSum < levels[higherLevel][3] - 4		-- User is allowed to have a total rating sum 4 lower than that needed to move up a level; below this, the level will decrease
end

function CalculateLevel()
	local currentRatings = {}
	SumRatings()
	print("Rating Sum:")
	print(studentInfo.ratingSum)
	local Rating = {}
	for i,j in ipairs(studentInfo.rating) do
		Rating[i] = studentInfo.rating[i] + studentInfo.ratingChange[i]
	end
	local level = 0
	for i,l in ipairs(levels) do
		if studentInfo.ratingSum < l[3] then return level end
		for j,rating in ipairs(Rating) do
			print(rating)
			if rating ~= 0 and rating < l[2] and currentRatings[math.ceil(rating / 2)] then return level end
		end
		level = i
		print("Level: ")
		print(level)

		-- Add the intervals in the next level to the list:
		for i,interval in ipairs(l[1]) do
			currentRatings[interval] = 1
		end
	end
	return level
end

function IncreaseLevel(newLevel)
	for i,interval in ipairs(levels[newLevel][1]) do
		studentInfo.rating[2 * interval - 1] = 1
		studentInfo.rating[2 * interval] = 1
	end
end

function DecreaseLevel(newLevel)
	for i,interval in ipairs(levels[newLevel + 1][1]) do
		studentInfo.rating[2 * interval - 1] = 0
		studentInfo.rating[2 * interval] = 1
	end
end


return state
