local state = {}

local backB = sButton("Back", 100, 100, 100, 50, "multiSetup", "menu")
local nextB = sButton("Start Match", love.graphics.getWidth() - 250, 100, 200, 50, "multiSetup", "test")

local questions

local timeLeft


-------------------- LOCAL FUNCTIONS:

function CombineOpponentRatings(ratings1, ratings2)
	for i,j in ipairs(ratings1) do
		print(ratings1[i])
	end
	for i,j in ipairs(ratings2) do
		print(ratings2[i])
	end

	local combinedRatings = {}
	for i=1,#ratings1 do
		local newRating = (ratings1[i] + ratings2[i]) / 2
		table.insert(combinedRatings, newRating)
	end
	return combinedRatings
end


-------------------- GLOBAL FUNCTIONS:

function state:new()
	return lovelyMoon.new(self)
end

function state:load()

end

function state:close()
end

function state:enable()
	studentInfo.inTournamentMatch = true 				-- If player goes through this state, they are about to participate in a tournament match
	-- local tournamentStatus = serv:fetchTournamentInfo()

	-- Find how long is left in the tournament match (if there is one):

	if studentInfo.tournament.RoundLength and studentInfo.tournamentMatch.StartDay then
		local dateTime = os.date('*t')
		local yday = dateTime.yday
		timeLeft = 24 - dateTime.hour + 24 * (tonumber(studentInfo.tournamentMatch.StartDay) + tonumber(studentInfo.tournament.RoundLength) - yday - 1)
	end
end

function state:disable()

	if not studentInfo.tournament or not studentInfo.tournamentMatch then
		return
	end

	local commonRating = CombineOpponentRatings(studentInfo.tournamentMatch.Ratings1, studentInfo.tournamentMatch.Ratings2)

	local commonRatingSum = 0 				-- Total sum of the ratings for both players, averaged
	for i,rat in ipairs(commonRating) do
		commonRatingSum = commonRatingSum + rat
	end


	love.math.setRandomSeed(studentInfo.tournamentMatch.Seed)
	questions = {}
	for i = 0, studentInfo.tournament.QsPerMatch do
		questions = CreateQuestion(questions, commonRating, commonRatingSum)
	end
	SendQuestions(questions)
	love.math.setRandomSeed(love.timer.getTime())
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
		love.graphics.print("You have "..timeLeft.." hours left to complete this match.", 300, 325)
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

function ReceiveMatchInfo(level1, level2)
	level1 = loadstring(level1)
	level2 = loadstring(level2)
	runningTournament = true
	newMatches = true
end
--]]

function PlayMatch()

end

return state
