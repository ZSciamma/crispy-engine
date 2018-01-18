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
local noteList = { 'C4', 'C#4', 'D4', 'D#4', 'E4', 'F4', 'F#4', 'G4', 'G#4', 'A4', 'A#4', 'B4', 'C5', 'C#5', 'D5', 'D#5', 'E5', 'F5', 'F#5', 'G5', 'G#5', 'A5', 'A#5', 'B5' }
local notes = {}
local notePause = 0.5							-- Pause between the two notes being played in a question
local questionPause = 2							-- Pause between questions
local noteCountdown 							-- Timer used throughout. Incremented in update(). 


-- Control:

local betweenTwoQuestions						-- True if the program is waiting to ask the next question
local waitingForAnswer							-- True if we are waiting for the user's answer to the last question


function state:new()
	return lovelyMoon.new(self)
end

function state:load()
	calculateButtonCoordinates()
	for i, button in ipairs(ansButtonCoords) do
		table.insert(ansButtons, ansButton(intervals[i], button[1], button[2], buttonRadius))
	end

	for i,note in ipairs(noteList) do
		table.insert(notes, {
			name = note,
			audio = love.audio.newSource('notes/'..note..'.ogg')
		})
	end
end


function state:close()
end


function state:enable()
	questionsAsked = 0							-- Reset upon arrival
	questions = {}
	for i = 0, qsPerTest do
		createQuestion()
	end

	betweenTwoQuestions = true
	waitingForAnswer = false

	noteCountdown = 1							-- First question will start 1 second after user's arrival.
end


function state:disable()
	clearButtons()
end


function state:update(dt)						-- Responsible for the specific timings
	if  waitingForAnswer then					-- Check if timer should be running
		local userAnswer = findPressed()
		if userAnswer then						-- Runs if user has clicked a button
			colourResults(userAnswer, math.abs(questions[questionsAsked + 1][3]))		-- Absolute because descending intervals are negative but still the same interval
			disallowInput()
			waitingForAnswer = false
			betweenTwoQuestions = true
			questionsAsked = questionsAsked + 1
		end
	else
		noteCountdown = noteCountdown - dt
	end


	if noteCountdown <= 0 then					-- Timer's up! Ask which event should happen
		if questionsAsked == qsPerTest then 
			lovelyMoon.disableState("solo")
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
			noteCountdown = questionPause
		end
		betweenTwoQuestions = not betweenTwoQuestions
	end
end


function state:draw()		
	for i, button in ipairs(ansButtons) do
		button:draw()
	end
	if questionsAsked ~= qsPerTest then
		love.graphics.print(questions[questionsAsked + 1][1], 100, 100)
		love.graphics.print(questions[questionsAsked + 1][2], 100, 150)
		love.graphics.print(questions[questionsAsked + 1][3], 100, 200)
	end
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

function calculateButtonCoordinates()					-- Calculates the position of each answer button, placing them like numbers on a clock
	for i = 1, 12 do
		local angle = math.pi * (1/2 - i/6)				-- math.pi / 2 - math.pi * i / 6
		table.insert(ansButtonCoords, { centerX + clockRadius * math.cos(angle), centerY - clockRadius * math.sin(angle) })
	end
end

function createQuestion()								-- At the moment, this creates a random question. Later, it will use spaced repetition.
	local int = love.math.random(-12, 12)				-- Interval to be tested; INTERVAL ~= 0 DUE TO 1-INDEXING
	while int == 0 do
		int = love.math.random(-12, 12)
	end
	local firstNote = love.math.random(1 - int / 2 + math.abs(int / 2), 24 - int / 2 - math.abs(int / 2))

	table.insert(questions, { firstNote, firstNote + int, int })	-- Stores the following: { note1 number, note2 number, interval } in the questions table
end

function playFirstNote(questionNumber)
	notes[questions[questionNumber][1]].audio:play()
end

function playSecondNote(questionNumber)
	notes[questions[questionNumber][2]].audio:play()
end

function findPressed()									-- Returns the number of the first button in the list to have been recently pressed by the user
	for i, button in ipairs(ansButtons) do
		if button.pressed == true then
			return i
		end
	end
	return nil
end

function colourResults(pressed, answer)					-- Colours buttons to show correct and incorrect answers
	if pressed == answer then
		ansButtons[pressed].correct = true
	else 
		ansButtons[pressed].incorrect = true
		ansButtons[answer].correct = true
	end
end

function clearButtons()									-- Resets all buttons so that only one button in the list ever has self.pressed = true
	for i, button in ipairs(ansButtons) do
		button.pressed = false
		button.correct = false
		button.incorrect = false
	end
end

function allowInput()
	for i, button in ipairs(ansButtons) do
		button.on = true
	end
end

function disallowInput()
	for i, button in ipairs(ansButtons) do 
		button.on = false
	end
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