-- In this state, the user can choose settings about the solo test they are about to take, such as the number of questions.

local state = {}

-- State change buttons:

local nextB = sButton("Next", love.graphics.getWidth() - 150, 100, 50, 50, "soloSetup", "test")
local backB = sButton("Back", 100, 100, 50, 50, "soloSetup", "menu")

local slider = Slider(300, 400, 500)

local questions 										-- Holds the questions to be asked in solo mode


-------------------- LOCAL FUNCTIONS:

local function createQuestion()
	local prob = love.math.random()
	local currentSum = 0
	local intervalNumber = 0
	for i,rating in ipairs(studentInfo.rating) do 					-- Ratio of probabilities equals ratio of ratings
		currentSum = currentSum + rating
		if prob < currentSum * (1 / studentInfo.ratingSum) then
			intervalNumber = i
			break
		end
	end
	local interval = math.floor((intervalNumber + 1) / 2)
	local lowerNote = love.math.random(1, #noteList - interval)
	local higherNote = lowerNote + interval

	if intervalNumber % 2 == 1 then			-- Figures out whether the interval should be ascending or descending (every other interval is asecnding)
		table.insert(questions, { lowerNote, higherNote, interval })
	else
		table.insert(questions, { higherNote, lowerNote, -interval })
	end
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
	studentInfo.inTournamentMatch = false				-- If player goes through soloSetup screen, the are playing alone and not in a tournament
	studentInfo.ratingSum = 0
	for i,rating in ipairs(studentInfo.rating) do
		studentInfo.ratingSum = studentInfo.ratingSum + rating
	end
end


function state:disable()
	studentInfo.qsPerTest = slider:value()
	questions = {}
	for i = 0, studentInfo.qsPerTest do
		createQuestion()
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

	love.graphics.print("Rating: "..studentInfo.ratingSum, 550, 200)
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

return state