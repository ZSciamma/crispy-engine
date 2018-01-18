-- This state shows the user a list of classes in which they are currently enrolled
local state = {}

-- State change buttons:

local backB = sButton("Back", 100, 100, 50, 50, "classes", "menu")

local input = textInput(400, 200, 300, 100)

function state:new()
	return lovelyMoon.new(self)
end


function state:load()

end


function state:close()
end


function state:enable()
	input:enable()

end


function state:disable()
	input:disable()
end


function state:update(dt)
	input:update(dt)
end


function state:draw()
	backB:draw()
	input:draw()
end

function state:keypressed(key, unicode)
	input:keypressed(key)

end

function state:keyreleased(key, unicode)
	input:keyreleased(key, unicode)
end

function state:mousepressed(x, y)
	backB:mousepressed(x, y)
	input:mousepressed(x, y)
end

function state:mousereleased(x, y)
	backB:mousereleased(x, y)
	input:mousereleased(x, y)
end


return state