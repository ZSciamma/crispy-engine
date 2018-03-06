local state = {}

local backB = sButton("Back", 100, 100, 50, 50, "multiTest", "menu")
local nextB = sButton("Play Match", love.graphics.getWidth() - 150, 100, 50, 50, "multiTest", function() PlayMatch() end)

local tournamentReady = false 				-- Is the student ready for a tournament (eg. have they joined a class)?
local runningTournament = false 			-- Is the student currently enrolled in a tournament?
local newMatches = false					-- Does the student have any matches waiting for them?

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
	if newMatches then nextB:draw() end
	if studentInfo.className == "" then 
		love.graphics.print("Please go to the 'New Class' section to connect to a class!", 300, 275)
	elseif not runningTournament then
		love.graphics.print("No ongoing tournament. Ask your teacher to create one!", 300, 275)
	elseif not newMatches then
		love.graphics.print("No new matches!", 300, 275)
	end
end

function state:keypressed(key, unicode)

end

function state:keyreleased(key, unicode)

end

function state:mousepressed(x, y, button)
	backB:mousepressed(x, y)
	if newMatches then nextB:mousepressed(x, y) end
end

function state:mousereleased(x, y, button)
	backB:mousereleased(x, y)
	if newMatches then nextB:mousereleased(x, y) end
end

function NoTournament()
	runningTournament = false
	newMatches = false
end

function NoMatches()
	runningTournament = true
	newMatches = false
end


function ReceiveMatchInfo(level1, level2)
	level1 = loadstring(level1)
	level2 = loadstring(level2)
	runningTournament = true
	newMatches = true
end

function PlayMatch()

end

return state