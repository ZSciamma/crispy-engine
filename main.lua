lovelyMoon = require("lib.lovelyMoon")
Object = require "lib.classic"
require 'items.stateButton'
require 'items.ansButton'
require 'items.slider'
require 'items.textInput'

-- Some useful extension functions for strings:

local metaT = getmetatable("")

metaT.__add = function(string1, string2)	--  + 
	return string1..string2
end

metaT.__mul = function(string1, toAdd)		--  * Adds t after the (i-1)th letter; toAdd = { letter, index }
	local length = string.len(string1)
	return string.sub(string1, 1, toAdd[2] - 1) + toAdd[1] + string.sub(string1, toAdd[2])
end

metaT.__div = function(string1, i)			-- / Removes the ith letter
	local length = string.len(string1)
	return string.sub(string1, 1, i - 1) + string.sub(string1, i + 1)
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

function love.load()
	love.window.setMode(1100, 600)
	love.graphics.setBackgroundColor(66, 167, 244)

	love.window.setTitle("Interval Training")

	states.menu = lovelyMoon.addState("states.menu", "menu")
	states.solo = lovelyMoon.addState("states.solo", "solo")
	states.multi = lovelyMoon.addState("states.multi", "multi")
	states.classes = lovelyMoon.addState("states.classes", "classes")
	states.options = lovelyMoon.addState("states.options", "options")
	states.stats = lovelyMoon.addState("states.statistics", "stats")
	states.summary = lovelyMoon.addState("states.summary", "summary")
	states.soloSetup = lovelyMoon.addState("states.soloSetup", "soloSetup")

	lovelyMoon.enableState("menu")
end

function love.update(dt)
	lovelyMoon.events.update(dt)
end


function love.draw()
	lovelyMoon.events.draw()
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