local state = {}

local backB = sButton("Back", 100, 100, 100, 50, "stats", "menu")		-- x = 500, y = 500 is also nice

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
	love.graphics.printf("User Information:", love.graphics.getWidth() / 2 - 8 * LetterWidth, 100, LetterWidth * 17, "center")
	love.graphics.print("User:", 300, 200)
	love.graphics.print(studentInfo.name, 600, 200)
	love.graphics.print("Level:", 300, 300)
	love.graphics.print(studentInfo.level, 600, 300)
	love.graphics.print("Total Answers:", 300, 400)
	love.graphics.print(studentInfo.statistics[1], 600, 400)
	love.graphics.print("Correct Answers:", 300, 500)
	if studentInfo.statistics[1] == 0 then
		love.graphics.print("100%", 600, 500)
	else
		love.graphics.print(math.floor((100 * studentInfo.statistics[2] / studentInfo.statistics[1]) + 0.5).."%" , 600, 500)
	end
end

function state:keypressed(key, unicode)

end

function state:keyreleased(key, unicode)

end

function state:mousepressed(x, y, button)
	backB:mousepressed(x, y)
end

function state:mousereleased(x, y, button)
	backB:mousereleased(x, y)
end

return state
