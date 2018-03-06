Notification = Confirmation:extend()

local buttonWidth = 200
local buttonHeight = 50
local buttonMargin = 25

function Notification:new(width, height, act)
	Notification.super.new(self, width, height)

	self.buttons = {}
	table.insert(self.buttons, sButton("Ok!", self.x + (self.width - buttonWidth) / 2, self.y + self.height - buttonHeight - buttonMargin, buttonWidth, buttonHeight, "state", function() act() end))
end


function Notification:update(dt)
	Notification.super.update(self, dt)
end


function Notification:draw()
	Notification.super.draw(self)
end


function Notification:mousepressed(x, y)
	Notification.super.mousepressed(self, x, y)
end



function Notification:mousereleased(x, y)
	Notification.super.mousereleased(self, x, y)
end