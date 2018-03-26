Notification = Object:extend()

local buttonWidth = 200
local buttonHeight = 50
local buttonMarginY = 25			-- Space between bottom of the popup and the button
local letterWidth = 9

function Notification:new(text, width, height)		-- Potentially also insert an 'accept' function
	self.width = width
	self.height = height
	self.x = (love.graphics.getWidth() - self.width) / 2
	self.y = (love.graphics.getHeight() - self.height) / 2
	self.text = text
	if letterWidth * string.len(self.text) < self.width - 16 then
		self.textX = love.graphics.getWidth() / 2 - math.floor(letterWidth * string.len(self.text) / 2)
		self.textLimit = string.len(self.text) * letterWidth
	else
		self.textX = self.x + 5
		self.textLimit = self.width - 16
	end
	self.textY = love.graphics.getHeight() / 2 - 30

	self.buttons = {}

	--table.insert(self.buttons, sButton("Ok!", self.x + (self.width - buttonWidth) / 2, self.y + self.height - buttonHeight - buttonMarginY, buttonWidth, buttonHeight, "state", function() accept() end))
	--table.insert(self.buttons, sButton("Ok!", self.x + (self.width - buttonWidth) / 2, self.y + self.height - buttonHeight - buttonMarginY, buttonWidth, buttonHeight, "state", function() accept() end))
	table.insert(self.buttons, sButton("Ok!", self.x + (self.width - buttonWidth) / 2, self.y + self.height - buttonHeight - buttonMarginY, buttonWidth, buttonHeight, "state", function() voidAlert() end))
end


function Notification:update(dt)
end


function Notification:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height)			-- Outline

	love.graphics.printf(self.text, self.textX, self.textY, self.textLimit, "center")

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
