-- This state shows the user the class in which they are currently enrolled
local state = {}

-- State change buttons:

local backB = sButton("Back", 100, 100, 100, 50, "joinClass", "menu")
local nextB = sButton("Join Class", love.graphics.getWidth() - 150, 100, 100, 50, "joinClass", function() JoinClass() end)
local classInput = textInput("Enter Class Code", 400, 200, 300, 100)		-- Used to input the name of the class to be joined

function state:new()
	return lovelyMoon.new(self)
end


function state:load()

end


function state:close()
end


function state:enable()
	classInput:enable()

end


function state:disable()
	classInput:disable()
	classInput.on = false
end


function state:update(dt)
	classInput:update(dt)
	if joinedClass == true then
		lovelyMoon.disableState("joinClass")
		lovelyMoon.enableState("class")
	end
end


function state:draw()
	backB:draw()
	nextB:draw()
	classInput:draw()
end

function state:keypressed(key, unicode)
	classInput:keypressed(key)
end

function state:textinput(text)
	classInput:textinput(text)
end

function state:mousepressed(x, y)
	backB:mousepressed(x, y)
	nextB:mousepressed(x, y)
	classInput:mousepressed(x, y)
end

function state:mousereleased(x, y)
	backB:mousereleased(x, y)
	nextB:mousereleased(x, y)
	classInput:mousereleased(x, y)
end

function JoinClass()
	--studentInfo.attemptedClassCode = classInput.text
	--classLocation = "172.28.198.21:63176"	--"192.168.0.12:60472"		-- REMOVE LATER ONCE IT IS NO LONGER NEEDED FOR DEBUGING
	serv:tryJoinClass(classInput.text)
end

function JoinComplete(className)
	studentInfo.foundClass = true
	studentInfo.joinClass = true
	studentInfo.className = className
	lovelyMoon.disableState("joinClass")
	lovelyMoon.enableState("class")
	addAlert("You succesfully joined "..className.."!", 500, 500)
end

return state
