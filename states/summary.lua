local state = {}

local nextB = sButton("Next", 500, 500, 100, 50, "summary", "menu")

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
	nextB:draw()
end

function state:keypressed(key, unicode)

end

function state:keyreleased(key, unicode)

end

function state:mousepressed(x, y, button)
	nextB:mousepressed(x, y)
end

function state:mousereleased(x, y, button)
	nextB:mousereleased(x, y)
end


return state
