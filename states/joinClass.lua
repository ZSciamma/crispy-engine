-- This state shows the user the class in which they are currently enrolled
local state = {}

-- State change buttons:

local backB = sButton("Back", 100, 100, 50, 50, "joinClass", "menu")
local nextB = sButton("Next", love.graphics.getWidth() - 150, 100, 50, 50, "joinClass", function() join() end)
local ipInput = textInput(400, 200, 300, 100)			-- Used to input the teacher's location
local classInput = textInput(400, 400, 300, 100)		-- Used to input the name of the class to be joined

function state:new()
	return lovelyMoon.new(self)
end


function state:load()

end


function state:close()
end


function state:enable()
	ipInput:enable()
	classInput:enable()

end


function state:disable()
	ipInput:disable()
	classInput:disable()
end


function state:update(dt)
	ipInput:update(dt)
	classInput:update(dt)
	if joinedClass == true then
		lovelyMoon.disableState("joinClass")
		lovelyMoon.enableState("class")
	end
end


function state:draw()
	backB:draw()
	nextB:draw()
	ipInput:draw()
	classInput:draw()
end

function state:keypressed(key, unicode)
	ipInput:keypressed(key)
	classInput:keypressed(key)

end

function state:keyreleased(key, unicode)
	ipInput:keyreleased(key, unicode)
	classInput:keyreleased(key)
end

function state:mousepressed(x, y)
	backB:mousepressed(x, y)
	nextB:mousepressed(x, y)
	ipInput:mousepressed(x, y)
	classInput:mousepressed(x, y)
end

function state:mousereleased(x, y)
	backB:mousereleased(x, y)
	nextB:mousereleased(x, y)
	ipInput:mousereleased(x, y)
	classInput:mousereleased(x, y)
end

function join()
	local classLocation = ipInput.text
	ClassName = classInput.text 			-- Temporarily makes the student part of the class (unless it is later found to be nonexistent)
	classLocation = "172.28.198.21:63176"	--"192.168.0.12:60472"		-- REMOVE LATER ONCE IT IS NO LONGER NEEDED FOR DEBUGING
	classLocation = loc 					-- Debugging
	foundClass = true
	serv:reachClass(classLocation)
end

function joinComplete()
	lovelyMoon.disableState("joinClass")
	lovelyMoon.enableState("class")
	foundClass = true
	joinedClass = true
end

return state