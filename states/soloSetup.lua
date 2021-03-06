-- In this state, the user can choose settings about the solo test they are about to take, such as the number of questions.

local state = {}

-- State change buttons:

local nextB = sButton("Next", love.graphics.getWidth() - 150, 100, 50, 50, "soloSetup", "solo")
local backB = sButton("Back", 100, 100, 50, 50, "soloSetup", "menu")

local slider = Slider(300, 400, 500)

function state:new()
	return lovelyMoon.new(self)
end


function state:load()

end


function state:close()
end


function state:enable()

end


function state:disable()
	qsPerTest = slider:value()
end


function state:update(dt)
	slider:update(dt)
end


function state:draw()
	slider:draw()
	nextB:draw()
	backB:draw()
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