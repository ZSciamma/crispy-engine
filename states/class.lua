-- This state shows the user the class in which they are currently enrolled
local state = {}

-- State change buttons:

local backB = sButton("Back", 100, 100, 100, 50, "class", "menu")

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

end


function state:update(dt)

end


function state:draw()
	backB:draw()
end

function state:keypressed(key, unicode)

end

function state:keyreleased(key, unicode)

end

function state:mousepressed(x, y)
	backB:mousepressed(x, y)
end

function state:mousereleased(x, y)
	backB:mousereleased(x, y)
end


return state
