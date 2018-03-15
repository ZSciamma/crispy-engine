local state = {}

local backB = sButton("Back", 100, 100, 50, 50, "multiSetup", "menu")
local nextB = sButton("Start Match", love.graphics.getWidth() - 150, 100, 50, 50, "multiSetup", "test")

function state:new()
	return lovelyMoon.new(self)
end


function state:load()

end


function state:close()
end


function state:enable()
	studentInfo.inTournamentMatch = true 				-- If player goes through this state, they are about to participate in a tournament match
	local tournamentStatus = serv:fetchTournamentInfo()
end


function state:disable()

end


function state:update(dt)
end


function state:draw()
	backB:draw()

	if studentInfo.className == "" then 
		love.graphics.print("Please go to the 'New Class' section to connect to a class!", 300, 275)
	elseif not studentInfo.tournament then
		love.graphics.print("No ongoing tournament. Ask your teacher to create one!", 300, 275)
	elseif not studentInfo.tournamentMatch then
		love.graphics.print("No new matches!", 300, 275)
	else
		love.graphics.print("Your next match is waiting. Click 'next' to start it!", 300, 275)
		nextB:draw()
	end
end

function state:keypressed(key, unicode)

end

function state:keyreleased(key, unicode)

end

function state:mousepressed(x, y, button)
	backB:mousepressed(x, y)
	if studentInfo.tournamentMatch then nextB:mousepressed(x, y) end
end

function state:mousereleased(x, y, button)
	backB:mousereleased(x, y)
	if studentInfo.tournamentMatch then nextB:mousereleased(x, y) end
end


--[[
function NoTournament()
	runningTournament = false
	newMatches = false
end

function NoMatches()
	runningTournament = true
	newMatches = false
end
--]]

function ReceiveMatchInfo(level1, level2)
	level1 = loadstring(level1)
	level2 = loadstring(level2)
	runningTournament = true
	newMatches = true
end

function PlayMatch()

end

return state