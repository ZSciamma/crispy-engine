Confirmation = Notification:extend()

local buttonWidth = 200
local buttonHeight = 50
local buttonSpacing = 25				-- Space between the buttons
local buttonMarginY = 25			-- Space between bottom of the popup and the buttons


function Confirmation:new(width, height, accept, reject)
	Confirmation.super.new(self, width, height)
	self.buttons = {}
	table.insert(self.buttons, sButton("No", self.x + (self.width - buttonSpacing) / 2 - buttonWidth, self.y + self.height - buttonHeight - buttonMarginY, buttonWidth, buttonHeight, "state", function() reject() end))
	table.insert(self.buttons, sButton("Yes", self.x + (self.width + buttonSpacing) / 2, self.y + self.height - buttonHeight - buttonMarginY, buttonWidth, buttonHeight, "state", function() accept() end))
end


function Confirmation:update(dt)
	Confirmation.super.update(self, dt)
end


function Confirmation:draw()
	Confirmation.super.draw(self)
end 


function Confirmation:mousepressed(x, y)
	Confirmation.super.mousepressed(self, x, y)
end


function Confirmation:mousereleased(x, y)
	Confirmation.super.mousereleased(self, x, y)
end