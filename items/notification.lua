Notification = Object:extend()

local buttonWidth = 200
local buttonHeight = 50
local buttonMarginY = 25			-- Space between bottom of the popup and the button

function Notification:new(width, height, accept)
	self.width = width
	self.height = height
	self.x = (love.graphics.getWidth() - self.width) / 2
	self.y = (love.graphics.getHeight() - self.height) / 2

	self.buttons = {}

	table.insert(self.buttons, sButton("Ok!", self.x + (self.width - buttonWidth) / 2, self.y + self.height - buttonHeight - buttonMarginY, buttonWidth, buttonHeight, "state", function() accept() end))
end


function Notification:update(dt)
end


function Notification:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height)			-- Outline

	for i,button in ipairs(self.buttons) do
		button:draw()
	end
end


function Notification:mousepressed(x, y)
	for i,button in ipairs(self.buttons) do
		button:mousepressed(x, y)
	end
end



function Notification:mousereleased(x, y)
	for i,button in ipairs(self.buttons) do
		button:mousereleased(x, y)
	end

end