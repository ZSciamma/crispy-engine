utf8 = require("utf8")
textInput = Object:extend()

local pointerTime = 0.6		 			-- How long the pointer stays onscreen
local pointerHeight = 15
local iBeamCursor = love.mouse.getSystemCursor("ibeam")
local arrowCursor = love.mouse.getSystemCursor("arrow")
local pointerMargin = 15

function textInput:new(emptyText, x, y, width, height, secure)
	self.on = true 						-- Is the field enabled?
	self.x = x 							-- x coordinate of the upper left corner
	self.y = y 							-- y coordinate of the upper left corner
	self.maxLength = math.floor((width - 2 * pointerMargin) / LetterWidth) 		
	self.width = self.maxLength * LetterWidth + 2 * pointerMargin
	self.height = height
	self.secure = secure or false		-- True if we want the text to be hidden
	self.secureText = "" 				-- Only applicable if secure is true
	self.pointery0 = self.y + (self.height - pointerHeight) / 2		-- Place pointer in middle of field
	self.pointerx0 = self.x + pointerMargin 	-- x coordinate of the pointer
	self.emptyText = emptyText 			-- Text displayed if field is empty

	self:reset() 
end

function textInput:reset()
	self.on = false
	self.text = ""							-- The text entered by the user
	self.active = false						-- True if the user clicked it and has not yet released
	self.pressed = false					-- True if the user is writing something
	self.pointerIndex = 0					-- How many letters in is the pointer?
	self.hover = false 						-- Is the mouse hovering above the text field?
	self.pointerIsVis = true				-- Is the text pointer visible?
	self.pointerTimer = 0 				
end

function textInput:update(dt)
	if not self.on then return end

	local mouseX = love.mouse.getX()
	local mouseY = love.mouse.getY()
	if mouseX >= self.x and mouseX <= self.x + self.width + self.width and mouseY >= self.pointery0 and mouseY <= self.pointery0 + pointerHeight then
		if not self.hover then
			love.mouse.setCursor(iBeamCursor)
			self.hover = true
		end
	elseif self.hover then
		love.mouse.setCursor(arrowCursor)
		self.hover = false
	end

	-- Place pointer below mouse (only in allowed positions):
	if self.active then
		if mouseX <= self.pointerx0 then
			self.pointerIndex = 0
		elseif mouseX >= self.pointerx0 + utf8.len(self.text) * LetterWidth then
			self.pointerIndex = utf8.len(self.text)
		else
			self.pointerIndex = round((mouseX - self.pointerx0) / LetterWidth)				-- Place pointer in nearest available position
		end
	end

	-- Make secure text consist of the right number of *'s:
	if self.secure and utf8.len(self.secureText) ~= utf8.len(self.text) then
		self.secureText = ""
		for i = 1,utf8.len(self.text) do
			self.secureText = self.secureText.."*"
		end
	end

	-- Toggle pointer visibility every second:
	if self.pressed then self.pointerTimer = self.pointerTimer - dt end
	if self.pointerTimer <= 0 then
		self.pointerTimer = pointerTime
		self.pointerIsVis = not self.pointerIsVis
	end
end

function textInput:draw()
	if not self.on then return end

	-- White background:
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("fill", self.x + 3, self.pointery0 - 10, self.width - 6, pointerHeight + 20)			-- Magic numbers for slight adjustment

	-- Black (or red) outline:
	love.graphics.setColor(0, 0, 0)
	if self.pressed then love.graphics.setColor(255, 0, 0) end
	love.graphics.rectangle("line", self.x + 3, self.pointery0 - 10, self.width - 6, pointerHeight + 20)			-- Magic numbers for slight adjustment

	love.graphics.setColor(0, 0, 0)

	-- Draw pointer:
	if self.pressed and self.pointerIsVis then
		local pointerXPos = self.pointerx0 + self.pointerIndex * LetterWidth
		love.graphics.line(pointerXPos, self.pointery0, pointerXPos, self.pointery0 + pointerHeight)
	end

	-- Print text:
	if self.secure then 			-- For *'s instead of the text
		love.graphics.print(self.secureText, self.pointerx0, self.pointery0 - 3)
	else
		love.graphics.print(self.text, self.pointerx0, self.pointery0 - 3)
	end

	-- Print different text if textbox empty:
	if utf8.len(self.text) == 0 then
		love.graphics.setColor(177, 177, 205)
		love.graphics.print(self.emptyText, self.pointerx0, self.pointery0 - 3)
	end
end

function textInput:mousepressed(x, y)
	if not self.on then return end

	if x >= self.x and x <= self.x + self.width and y >= self.pointery0 and y <= self.pointery0 + pointerHeight then
		self.active = true
		self.pressed = true
	else
		self.pressed = false
	end
end

function textInput:mousereleased(x, y)
	if not self.on then return end

	self.active = false
	if self.pressed then
		self.pointerTimer = pointerTime
		self.pointerIsVis = true
	end
end

function textInput:textinput(text)
	if not (self.on and self.pressed) then return end
	if utf8.len(self.text) >= self.maxLength then return end

	--self.text = string.sub(self.text, 1, self.pointerIndex)..text..string.sub(self.text, self.pointerIndex + 1)
	local byteOffset = utf8.offset(self.text, self.pointerIndex + 1)
	if self.pointerIndex == utf8.len(self.text) then
		self.text = self.text..text
		self.pointerIndex = self.pointerIndex + 1
	elseif byteOffset then
		self.text = string.sub(self.text, 1, byteOffset - 1)..text..string.sub(self.text, utf8.offset(self.text, self.pointerIndex + 1))
		self.pointerIndex = self.pointerIndex + 1
	end
end

function textInput:keypressed(key)						-- For keys with special functions (self-evident)
	if not (self.on and self.pressed) then return end

	local length = utf8.len(self.text)
	if key == "backspace" then
		if self.pointerIndex <= 0 then return end
		local byteOffset = utf8.offset(self.text, self.pointerIndex)
		if self.pointerIndex == length then
			self.text = string.sub(self.text, 1, byteOffset - 1)
			self.pointerIndex = self.pointerIndex - 1
		elseif byteOffset then
			self.text = string.sub(self.text, 1, byteOffset - 1)..string.sub(self.text, utf8.offset(self.text, self.pointerIndex + 1))
			self.pointerIndex = self.pointerIndex -1
		end
	elseif key == "right" then
		if self.pointerIndex >= length then return end
		self.pointerIndex = self.pointerIndex + 1
	elseif key == "left" then
		if self.pointerIndex <= 0 then return end
		self.pointerIndex = self.pointerIndex - 1
	elseif key == "up" then self.pointerIndex = 0 return
	elseif key == "down" then self.pointerIndex = length return
	end
end

function textInput:disable()
	self:reset()
end

function textInput:enable()
	self.on = true
end

function textInput:secure()				-- Hide the text in it
	self.secure = true
end

function textInput:unsecure()			-- Show the text in it
	self.secure = false
end

function textInput:checkDelimiter()		-- Checks whether current input text contains the delimiter
	local message = split(self.text)
	if #message > 1 then
		return true
	else
		return false
	end
end

function textInput:passwordStrength()	-- Checks whether a password meets all the strength requirements
	local minLength = 6

	if utf8.len(self.text) < minLength then		-- Length requirement
		return false
	end

	if not string.match(self.text, "%l") then return false end		-- There must be a lowercase character
	if not string.match(self.text, "%u") then return false end		-- There must be an uppercase character
	if not string.match(self.text, "%d") then return false end		-- There must be a digit
	if not string.match(self.text, "%W") then return false end		-- There must be a non-alphanumeric character

	return true
end
