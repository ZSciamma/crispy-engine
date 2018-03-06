Confirmation = Object:extend()

local buttonWidth = 200
local buttonHeight = 50
local buttonMargin = 25

function Confirmation:new(width, height)
	self.width = width
	self.height = height
	self.x = (love.graphics.getWidth() - self.width) / 2
	self.y = (love.graphics.getHeight() - self.height) / 2

	self.buttons = {}

end


function Confirmation:update(dt)

end


function Confirmation:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height)			-- Outline

	for i,button in ipairs(self.buttons) do
		button:draw()
	end
end 


function Confirmation:mousepressed(x, y)
	for i,button in ipairs(self.buttons) do
		button:mousepressed(x, y)
	end
end


function Confirmation:mousereleased(x, y)
	for i,button in ipairs(self.buttons) do
		button:mousereleased(x, y)
	end
end