local state = {}

-- Graphics:

local centerX = love.graphics.getWidth() / 2	-- Center of the screen
local centerY = love.graphics.getHeight() / 2
local clockRadius = 220							-- Radius of the 'clock' button arrangement
local buttonRadius = 50							-- Radius of each answer button
local ansButtonCoords = {}						-- Stores the coordinates of the buttons used to answer questions (after calculation)
local ansButtons = {}							-- Stores the answer buttons

-- Questions:

local questions 								-- Stores each question for the current test as follows:   { interval no., starting pitch, wasCorrect }
local questionsAsked 							-- Number of questions asked so far
local streak
local notePause = 0.5							-- Pause between the two notes being played in a question
local questionPause = 2							-- Pause between questions
local noteCountdown 							-- Timer used throughout. Incremented in update(). 
local answerTime 
local totalScore
local maxAnswerTime = 5


-- Control:

local betweenTwoQuestions						-- True if the program is waiting to ask the next question
local waitingForAnswer							-- True if we are waiting for the user's answer to the last question


-------------------- LOCAL FUNCTIONS:

local function clearButtons()									-- Resets all buttons so that only one button in the list ever has self.pressed = true
	for i, button in ipairs(ansButtons) do
		button.pressed = false
		button.correct = false
		button.incorrect = false
	end
end

local function allowInput()
	for i, button in ipairs(ansButtons) do
		button.on = true
	end
end

local function disallowInput()
	for i, button in ipairs(ansButtons) do 
		button.on = false
	end
end

local function exponentialFunction(x)
	if x >= 1 then 
		return Math.exp(1 - x) 
	elseif x >= 0 then 
		return 0 
	end
end

local function playFirstNote(questionNumber)
	notes[questions[questionNumber][1]].audio:play()
end

local function playSecondNote(questionNumber)
	notes[questions[questionNumber][2]].audio:play()
end

local function findPressed()									-- Returns the number of the first button in the list to have been recently pressed by the user
	for i, button in ipairs(ansButtons) do
		if button.pressed == true then
			return i
		end
	end
	return nil
end

local function calculateAnswerScore(time)						-- Calculates the score the student gets for answering the question correctly. Answering immediately receives twice as many points as answering after 1 second
	local fullScore = 1000										-- Score if question is answered almost immediately
	local streakExtra = 100										-- Extra points per previous correct answer
	local rawScore = 0
	if time < 0.5 then 
		rawScore = fullScore
	elseif time > maxAnswerTime then 
		rawScore = fullScore / 2
	else
		rawScore = fullScore * (1 - ((time / maxAnswerTime) / 2))
	end

	rawScore = rawScore + streakExtra * (math.min(streak, 5) - 1)		-- Streak limited to 5

	return rawScore
end

local function colourResults(pressed, answer)					-- Colours buttons to show correct and incorrect answers
	if pressed == answer then
		ansButtons[pressed].correct = true
	else 
		ansButtons[pressed].incorrect = true
		ansButtons[answer].correct = true
	end
end

local function updateScore(pressed, answer, time)				-- Update the streak, interval ratings, and score of the student depending on whether their answer to the question was correct. Called after every question answer
	local index = 0
	local questionScore

	if answer > 0 then											-- For ascending intervals
		index = 2 * answer - 1
	else
		index = 2 * math.abs(answer)
	end

	if pressed == math.abs(answer) then									-- If answer is correct
		if studentInfo.record[index] < 0 then						-- Does this interval have a negative streak? Bring it back to 1
			studentInfo.record[index] = 1
		else
			studentInfo.record[index] = studentInfo.record[index] + 1
		end
		if studentInfo.record[index] >= 3 then						-- Is it time to increase the rating?
			if studentInfo.ratingChange[index] < 1 then				-- Rating hasn't already been increased higher than today's starting point, else don't increase it
				studentInfo.ratingChange[index] = studentInfo.ratingChange[index] + 1
				studentInfo.record[index] = 0						-- Positive streak goes back to 0
			end
		end

		streak = streak + 1
		questionScore = calculateAnswerScore(time)					-- Calculate the score gained for this question

	else
		if studentInfo.record[index] > 0 then
			studentInfo.record[index] = -1
		else
			studentInfo.record[index] = studentInfo.record[index] - 1
		end
		if studentInfo.record[index] <= -3 then 
			if studentInfo.ratingChange[index] > -1 then
				studentInfo.ratingChange[index] = studentInfo.ratingChange[index] - 1
				studentInfo.record[index] = 0
			end
		end

		streak = 0
		questionScore = 0
	end

	totalScore = Round(totalScore + questionScore)
end


-------------------- GLOBAL FUNCTIONS:

function state:new()
	return lovelyMoon.new(self)
end

function state:load()
	CalculateButtonCoordinates()
	for i, button in ipairs(ansButtonCoords) do
		table.insert(ansButtons, ansButton(intervals[i], button[1], button[2], buttonRadius))
	end
end


function state:close()
end


function state:enable()
	questionsAsked = 0							-- Reset upon arrival

	betweenTwoQuestions = true
	waitingForAnswer = false

	noteCountdown = 1							-- First question will start 1 second after user's arrival.

	totalScore = 0
	streak = 0
end


function state:disable()
	clearButtons()
	if studentInfo.inTournamentMatch then
		serv:sendMatchResult(totalScore)
		studentInfo.tournamentMatch = nil			
		studentInfo.inTournamentMatch = false
	end
end


function state:update(dt)						-- Responsible for the specific timings
	if  waitingForAnswer then					-- Check if timer should be running
		local userAnswer = findPressed()
		answerTime = answerTime + dt
		if userAnswer then						-- Runs if user has clicked a button
			colourResults(userAnswer, math.abs(questions[questionsAsked + 1][3]))		-- Absolute because descending intervals are negative but still the same interval
			disallowInput()
			updateScore(userAnswer, questions[questionsAsked + 1][3], answerTime)
			waitingForAnswer = false
			betweenTwoQuestions = true
			questionsAsked = questionsAsked + 1
		end
	else
		noteCountdown = noteCountdown - dt
	end


	if noteCountdown <= 0 then					-- Time's up! Ask which event should happen
		if questionsAsked == studentInfo.qsPerTest then 
			lovelyMoon.disableState("test")
			lovelyMoon.enableState("summary")
		elseif betweenTwoQuestions then			-- Time to ask the next question
			clearButtons()
			love.audio.stop()					-- IMPORTANT: stops and rewinds all audio to allow the same note to be played in consecutive questions
			playFirstNote(questionsAsked + 1)
			noteCountdown = notePause
		else									-- Time to play the second note
			playSecondNote(questionsAsked + 1) 
			waitingForAnswer = true
			allowInput()
			answerTime = 0
			noteCountdown = questionPause
		end
		betweenTwoQuestions = not betweenTwoQuestions
	end
end


function state:draw()	
	local a = ""
	local b = ""
	local c = ""

	for i,j in ipairs(studentInfo.rating) do
		a = a..j
	end
	for i,j in ipairs(studentInfo.record) do
		b = b..j
	end
	for i,j in ipairs(studentInfo.ratingChange) do
		c = c..j
	end

	for i, button in ipairs(ansButtons) do
		button:draw()
	end
	if questionsAsked ~= studentInfo.qsPerTest then
		love.graphics.print(questions[questionsAsked + 1][1], 100, 100)
		love.graphics.print(questions[questionsAsked + 1][2], 100, 150)
		love.graphics.print(questions[questionsAsked + 1][3], 100, 200)
	end

	love.graphics.print("Rating: "..a, 50, 450)
	love.graphics.print("Record: "..b, 50, 500)
	love.graphics.print("Change: "..c, 50, 550)
	love.graphics.print("Score: "..totalScore, 900, 100)
end

function state:keypressed(key, unicode)
end

function state:keyreleased(key, unicode)

end

function state:mousepressed(x, y)
	for i, button in ipairs(ansButtons) do
		button:mousepressed(x, y)
	end
end

function state:mousereleased(x, y)
	for i, button in ipairs(ansButtons) do
		button:mousereleased(x, y)
	end
end

function CalculateButtonCoordinates()					-- Calculates the position of each answer button, placing them like numbers on a clock
	for i = 1, 12 do
		local angle = math.pi * (1/2 - i/6)				-- math.pi / 2 - math.pi * i / 6
		table.insert(ansButtonCoords, { centerX + clockRadius * math.cos(angle), centerY - clockRadius * math.sin(angle) })
	end
end

--[[
function createQuestion()								-- At the moment, this creates a random question. Later, it will use spaced repetition.
	local int = love.math.random(-12, 12)				-- Interval to be tested; INTERVAL ~= 0 DUE TO 1-INDEXING
	while int == 0 do
		int = love.math.random(-12, 12)
	end
	local firstNote = love.math.random(1 - int / 2 + math.abs(int / 2), 24 - int / 2 - math.abs(int / 2))

	table.insert(questions, { firstNote, firstNote + int, int })	-- Stores the following: { note1 number, note2 number, interval } in the questions table
end
--]]


function SendQuestions(_questions)						-- Called from other screens (soloSetup or multiSetup) to give the questions for this test.
	questions = _questions
end

function Round(x)
	return math.floor(x * 1000 + 0.5) / 1000
end



return state




--[[
questions must all be written before the test

fetch next questions 		Done
play first note 			Done
calculate second note 		Done
	pause 					Done
play second note      		Done
record answer  
show correct answer    		Done
write next question    		Done

--]]