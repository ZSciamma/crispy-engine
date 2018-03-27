-- In this state, the user can choose settings about the solo test they are about to take, such as the number of questions.

local state = {}

-- State change buttons:

local nextB = sButton("Start Training", love.graphics.getWidth() - 200, 100, 100, 50, "soloSetup", "test")
local backB = sButton("Back", 100, 100, 100, 50, "soloSetup", "menu")

local slider = Slider(300, 400, 500)

local questions 										-- Holds the questions to be asked in solo mode


function CreateQuestion(questionTable, ratingTable, ratingSum)
	local prob = love.math.random()
	local totalProb = 0
	for i,j in ipairs(ratingTable) do
		if j ~= 0 then totalProb = totalProb + 1 / j end
	end
	local currentSum = 0
	local intervalNumber = 0
	for i,rating in ipairs(ratingTable) do 					-- Ratio of probabilities equals ratio of ratings
		if rating ~= 0 then currentSum = currentSum + 1 / rating end
		if prob * totalProb < currentSum then
			intervalNumber = i
			break
		end
	end
	local interval = math.floor((intervalNumber + 1) / 2)
	local lowerNote = love.math.random(1, #noteList - interval)
	local higherNote = lowerNote + interval

	if intervalNumber % 2 == 1 then			-- Figures out whether the interval should be ascending or descending (every other interval is asecnding)
		table.insert(questionTable, { lowerNote, higherNote, interval })
	else
		table.insert(questionTable, { higherNote, lowerNote, -interval })
	end

	return questionTable
end

function state:new()
	return lovelyMoon.new(self)
end


function state:load()

end


function state:close()

end


function state:enable()
	studentInfo.inTournamentMatch = false				-- If player goes through soloSetup screen, the are playing alone and not in a tournament
	SumRatings()
end


function state:disable()
	studentInfo.qsPerTest = slider:value()
	questions = {}
	for i = 0, studentInfo.qsPerTest do
		questions = CreateQuestion(questions, studentInfo.rating, studentInfo.ratingSum)
	end
	SendQuestions(questions)
end


function state:update(dt)
	slider:update(dt)
end


function state:draw()
	slider:draw()
	nextB:draw()
	backB:draw()

	love.graphics.printf("Solo Training:", love.graphics.getWidth() / 2 - 7 * LetterWidth, 100, LetterWidth * 14, "center")
	love.graphics.print("Questions Per Match: "..slider:value(), 300, 300)
end

function state:keypressed(key, unicode)

end

function state:keyreleased(key, unicode)

end

function state:mousepressed(x, y)
	slider:mousepressed(x, y)
	nextB:mousepressed(x, y)
	backB:mousepressed(x, y)
end

function state:mousereleased(x, y)
	slider:mousereleased(x, y)
	nextB:mousereleased(x, y)
	backB:mousereleased(x, y)
end

function SumRatings()			-- Calculates the sum of the rating for every interval
	studentInfo.ratingSum = 0
	for i,rating in ipairs(studentInfo.rating) do
		studentInfo.ratingSum = studentInfo.ratingSum + rating
	end
end

return state
