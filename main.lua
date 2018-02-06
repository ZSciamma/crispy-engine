-- Not mine (sources given in report):
lovelyMoon = require("lib.lovelyMoon")
Object = require "lib.classic"
require 'lib.tableSer'

-- Mine:
require 'items.stateButton'
require 'items.ansButton'
require 'items.slider'
require 'items.textInput'

require 'comm'

	--************ SAVE IN FILE: *************--
	-- Make student input this upon opening the app:

if not love.filesystem.exists("StudentInfoSave") then
	studentInfo = {
		new = true,					-- True if the user has never opened the app (and so not set the profile and class information)
		myForename = "Zac",
		mySurname = "Sciamma",
		myEmail = "yo.yoyo@gmail.com",	
		myPassword = "Blugalugalug",			-- Student's password, set before using the app
		profileComplete = false,
		joinedClass = false,				-- True if the student has joined a class
		StudentID = "",					-- The student's ID within the class
		teacherName = "",
		className = "",
		serverLoc = "localhost:6789"	-- Location of the server
	}
else
	studentInfo = loadstring(love.filesystem.read("StudentInfoSave"))()
end

attemptedClassCode = ""			-- Name of the class the student's trying to join 
foundClass = false				-- True if the student has joined or is attempting to join a class
inTournamentMatch = false		-- Is the user currently doing a match to participate in a tournament?



-- Some useful extension functions for strings:

local metaT = getmetatable("")

metaT.__add = function(string1, string2)	--  + 
	return string1..", "..string2
end

metaT.__mul = function(string1, toAdd)		--  * Adds t after the (i-1)th letter; toAdd = { letter, index }
	local length = string.len(string1)
	return string.sub(string1, 1, toAdd[2] - 1)..toAdd[1]..string.sub(string1, toAdd[2])
end

metaT.__div = function(string1, i)			-- / Removes the ith letter
	local length = string.len(string1)
	return string.sub(string1, 1, i - 1)..string.sub(string1, i + 1)
end

--[[
lick = require 'lib.lick'			-- Used for live coding; reloads the program after every save
lick.reset = true					-- Causes problems, such as the inability to set a background color
--]]

states = {}

-- This is the order of intervals used throughout for easy reference (1-indexed). Te ascending intervals are 1 to 12; the descending intervals
-- are 13 to 24 in the same order.

intervals = { "Minor Second", "Major Second", "Minor Third", "Major Third", "Perfect Fourth", "Tritone", "Perfect Fifth", "Minor Sixth", "Major Sixth", "Minor Seventh", "Major Seventh", "Octave" }

qsPerTest = 5						-- Global because it's needed in several states. Can be changed before each test.

serverTime = 1
serverTimer = serverTime

function love.load()
	love.window.setMode(1100, 600)
	love.graphics.setBackgroundColor(66, 167, 244)

	love.window.setTitle("Interval Training")

	states.menu = lovelyMoon.addState("states.menu", "menu")
	states.solo = lovelyMoon.addState("states.solo", "solo")
	states.multi = lovelyMoon.addState("states.multi", "multi")
	states.joinClass = lovelyMoon.addState("states.joinClass", "joinClass")
	states.class = lovelyMoon.addState("states.class", "class")
	states.options = lovelyMoon.addState("states.options", "options")
	states.stats = lovelyMoon.addState("states.statistics", "stats")
	states.summary = lovelyMoon.addState("states.summary", "summary")
	states.soloSetup = lovelyMoon.addState("states.soloSetup", "soloSetup")

	lovelyMoon.enableState("menu")

	serv = Server()

	serv.on = true
end

function love.update(dt)
	lovelyMoon.events.update(dt)
	if serverTimer <= 0 and foundClass then
		serverTimer = serverTime
		if serv.on then serv:update(dt) end
	else
		serverTimer = serverTimer - dt
	end
end

function love.draw()
	lovelyMoon.events.draw()
	if serv.on then serv:draw() end
end

function love.keyreleased(key)
	lovelyMoon.events.keyreleased(key)
end


function love.keypressed(key)
	lovelyMoon.events.keypressed(key)
end

function love.mousepressed(x, y)
	lovelyMoon.events.mousepressed(x, y)
end

function love.mousereleased(x, y)
	lovelyMoon.events.mousereleased(x, y)
end 

function love.quit()
	love.filesystem.write("StudentInfoSave", table.serialize(studentInfo))
	if serverPeer ~= 0 then serverPeer:disconnect_later(); serv:update() end
end