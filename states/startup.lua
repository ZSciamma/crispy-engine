local state = {}

local createNewAccount = sButton("Create New Account", 400, 100, 300, 100, "startup", "createAccount")
local loginToAccount = sButton("Login to Account", 400, 300, 300, 100, "startup", "login")

function state:new()
	return lovelyMoon.new(self)
end


function state:load()

end


function state:close()
end


function state:enable()
	-- When the user logs out, we want to reset these variables:
	studentInfo = {						
		attemptedClassCode = "",		-- Name of the class the student's trying to join 
		foundClass = false,				-- True if the student has joined or is attempting to join a class
		className = "",
		rating = {},
		inTournamentMatch = false,		-- Is the user currently doing a match to participate in a tournament?
		record = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },			-- Which answers have been answered correctly and incorrectly	
		ratingChange = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, 	-- How much the rating has changed this session for each interval
		qsPerTest = 5,
		ratingSum = 0	
	}
end

function state:disable()

end


function state:update(dt)
end


function state:draw()
	createNewAccount:draw()
	loginToAccount:draw()	
end

function state:keypressed(key, unicode)

end

function state:keyreleased(key, unicode)

end

function state:mousepressed(x, y, button)
	createNewAccount:mousepressed(x, y)
	loginToAccount:mousepressed(x, y)
end

function state:mousereleased(x, y, button)
	createNewAccount:mousereleased(x, y)
	loginToAccount:mousereleased(x, y)
end

return state