-- This is the main menu. The user is brought here upon launching the application and can return after tests.

local state = {}

-- The list of state changes required is as follows (from the first state to the second state within each bracket):


menuButtons = {}
menuButtonInfo = {}

whiteKeys = { 0, 50, 100, 450, 500, 550 }
blackKeys = { 35, 90, 180, 240, 330, 385, 440, 530, 590 }


function state:new()
	return lovelyMoon.new(self)

end


function state:load()

end


function state:close()
end


function state:enable()
	menuButtons = {}
	menuButtonInfo = {}

	if studentInfo.className == "" or not studentInfo.className then classStatus = "joinClass" else classStatus = "class" end

	menuButtonInfo = {
		{ "Solo", "soloSetup" },			-- { Button text, state name }
		{ "Multiplayer", "multiSetup" },
		{ "Class", classStatus },			-- Directs the student to join a class or see their current class
		{ "Options", "options" },
		{ "Statistics", "stats" },
		{ "Log Out", function() logout() end }
		--{ "Quit", 400, 450, 300, 50, function() love.event.quit() end }
	}

	for i, button in ipairs(menuButtonInfo) do
		table.insert(menuButtons, sButton(button[1], 400, 100 + 50 * i, 300, 50, "menu", button[2]))				-- DRY: most parameters are common to every button in the menu
	end
end


function state:disable()

end


function state:update(dt)
end


function state:draw()
	for i, button in ipairs(menuButtons) do
		button:draw()
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("line", button.x, button.y, button.width, button.height)
	end

	for i, keyPos in ipairs(whiteKeys) do
		love.graphics.setColor (255, 255, 255)
		love.graphics.rectangle("fill", 400, keyPos, 300, 50)
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("line", 400, keyPos, 300, 50)
		love.graphics.rectangle("line", 400, keyPos, 300, 50)				-- Double rectangle outline looks sharper
	end

	love.graphics.setColor(0, 0, 0)

	for i, keyPos in ipairs(blackKeys) do
		love.graphics.rectangle("fill", 500, keyPos, 200, 30)				-- The length and width of the black keys remain constant
	end

	if studentInfo.rating ~= {} then love.graphics.print(studentInfo.rating, 800, 300) end
end

function state:keypressed(key, unicode)
end

function state:keyreleased(key, unicode)

end

function state:mousepressed(x, y)
	for i, button in ipairs(menuButtons) do
		button:mousepressed(x, y)
	end

end

function state:mousereleased(x, y)
	for i, button in ipairs(menuButtons) do
		button:mousereleased(x, y)
	end
end

function logout()					-- When the logout button is pressed, the program attempts to log out
	updateRatings()
	local encodedRating = encodeRatings()
	serv:tryLogout(encodedRating)
end

function logoutComplete()			-- When the server confirms the logout, the program returns to the startup screen.
	lovelyMoon.switchState("menu", "startup")
end

function updateRatings()			-- Updates the student's ratings depending on their progress that day.
	for i,j in ipairs(studentInfo.rating) do
		newRating = studentInfo.rating[i] + studentInfo.ratingChange[i]
		if newRating >= 1 then		-- Limits ratings to greater than 0
			studentInfo.rating[i] = newRating
		end
	end
end

function encodeRatings()
	local encoded = ""
	for i,j in ipairs(studentInfo.rating) do
		if i == 1 then 
			encoded = j
		else
			encoded = encoded.."."..j
		end
	end
	return encoded
end


return state