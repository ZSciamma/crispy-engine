-- Not mine (sources given in report):
lovelyMoon = require("lib.lovelyMoon")
Object = require "lib.classic"
require 'lib.tableSer'

-- Mine:
require 'items.stateButton'
require 'items.ansButton'
require 'items.slider'
require 'items.textInput'
require 'items.notification'
require 'items.confirmation'

require 'comm'

studentInfo = {}

serverLoc = "localhost:6789"	-- Location of the server

-- Some useful extension functions for strings:

local metaT = getmetatable("")

metaT.__add = function(string1, string2)	--  + 
	return string1.."....."..string2
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
types = { "Asc", "Dsc"}				-- Ascending and descending intervals
noteList = { 'C4', 'C#4', 'D4', 'D#4', 'E4', 'F4', 'F#4', 'G4', 'G#4', 'A4', 'A#4', 'B4', 'C5', 'C#5', 'D5', 'D#5', 'E5', 'F5', 'F#5', 'G5', 'G#5', 'A5', 'A#5', 'B5' }
notes = {}


serverTime = 0.2
serverTimer = serverTime
alert = 0						-- The alert currently onscreen. 0 if no alert is present.

function love.load()
	love.window.setMode(1100, 600)
	love.graphics.setBackgroundColor(66, 167, 244)

	love.window.setTitle("Interval Training")

	font = love.graphics.newFont("RobotoMono-Regular.ttf", 15)
	love.graphics.setFont(font)

	states.startup = lovelyMoon.addState("states.startup", "startup")
	states.createAccount = lovelyMoon.addState("states.createAccount", "createAccount")
	states.login = lovelyMoon.addState("states.login", "login")
	states.menu = lovelyMoon.addState("states.menu", "menu")
	states.test = lovelyMoon.addState("states.test", "test")
	states.multiSetup = lovelyMoon.addState("states.multiSetup", "multiSetup")
	states.joinClass = lovelyMoon.addState("states.joinClass", "joinClass")
	states.class = lovelyMoon.addState("states.class", "class")
	states.options = lovelyMoon.addState("states.options", "options")
	states.stats = lovelyMoon.addState("states.statistics", "stats")
	states.summary = lovelyMoon.addState("states.summary", "summary")
	states.soloSetup = lovelyMoon.addState("states.soloSetup", "soloSetup")

	lovelyMoon.enableState("startup")

	-- Load the notes:

	for i,note in ipairs(noteList) do
		table.insert(notes, {
			name = note,
			audio = love.audio.newSource('notes/'..note..'.ogg')
		})
	end

	serv = Server()
end

function love.update(dt)
	lovelyMoon.events.update(dt)
	if not serv.on then return end
	if serverTimer <= 0 then
		serverTimer = serverTime
		serv:update(dt)
	else
		serverTimer = serverTimer - dt
	end

	if alert ~= 0 then alert:update(dt) end
end

function love.draw()
	lovelyMoon.events.draw()
	serv:draw()

	if alert ~= 0 then alert:draw() end
end

function love.keyreleased(key)
	-- Deal with alerts onscreen:
	if alert ~= 0 then
		return
	end
	-- No alerts:
	lovelyMoon.events.keyreleased(key)
end


function love.keypressed(key)
	-- Deal with alerts onscreen:
	if alert ~= 0 then
		return
	end
	-- No alerts:
	lovelyMoon.events.keypressed(key)
end

function love.mousepressed(x, y)
	-- Deal with alerts onscreen:
	if alert ~= 0 then
		alert:mousepressed(x, y)
		return
	end
	-- No alerts:
	lovelyMoon.events.mousepressed(x, y)
end

function love.mousereleased(x, y)
	-- Deal with alerts onscreen:
	if alert ~= 0 then
		alert:mousereleased(x, y)
		return
	end
	-- No alerts:
	lovelyMoon.events.mousereleased(x, y)
end 

function love.quit()
	if serverPeer ~= 0 then serverPeer:disconnect_later(); serv:update() end
end