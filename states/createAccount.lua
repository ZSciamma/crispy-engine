local state = {}

local accountInputs = {
	Name = textInput("Name", 400, 150, 300, 25),
	Surname = textInput("Surname", 400, 200, 300, 25),
	Email = textInput("Email", 400, 250, 300, 25),
	Password1 = textInput("Password", 400, 300, 300, 25, true),
	Password2 = textInput("Re-Enter Password", 400, 350, 300, 25, true)
}

local backB = sButton("Back", 100, 100, 50, 50, "createAccount", "startup")
local enterB = sButton("Create Account", 400, 450, 300, 75, "createAccount", function() validateNewAccount() end)

local errorReason = ""					-- Why the user's account creation failed
local serverWaitTime = 5				-- Time after which the server is declared unavaliable
local serverWaitTimer = serverWaitTime
local serverTried = false				-- Are we trying to connect to the server?

function state:new()
	return lovelyMoon.new(self)
end


function state:load()

end


function state:close()
end


function state:enable()
	for i,input in pairs(accountInputs) do
		input:enable()
	end
end


function state:disable()
	for i,input in pairs(accountInputs) do
		input:disable()
	end
	accountFailed()						-- Reset errors and timers
end


function state:update(dt)
	for i,input in pairs(accountInputs) do
		input:update(dt)
	end

	if serverTried then
		if serverWaitTimer <= 0 then 
			serverTried = false
			accountFailed("The server is currently unavaliable. Please try again later.")
		else
			serverWaitTimer = serverWaitTimer - dt
		end
	end
end


function state:draw()
	backB:draw()
	enterB:draw()
	for i,input in pairs(accountInputs) do
		input:draw()
	end

	accountInputs.Name:draw()

	love.graphics.setColor(255, 0, 0)
	love.graphics.print(errorReason, 400, 415)
end

function state:keypressed(key, unicode)
	for i,input in pairs(accountInputs) do
		input:keypressed(key)
	end
end

function state:keyreleased(key, unicode)
	for i,button in pairs(accountInputs) do
		button:keyreleased(key)
	end
end

function state:mousepressed(x, y, button)
	backB:mousepressed(x, y)
	enterB:mousepressed(x, y)
	for i,input in pairs(accountInputs) do
		input:mousepressed(x, y)
	end
end

function state:mousereleased(x, y, button)
	backB:mousereleased(x, y)
	enterB:mousereleased(x, y)
	for i,input in pairs(accountInputs) do
		input:mousereleased(x, y)
	end
end

function validateNewAccount() 						-- Ask the server to create the new account
	local name = accountInputs.Name.text
	local surname = accountInputs.Surname.text
	local email = accountInputs.Email.text
	local password1 = accountInputs.Password1.text
	local password2 = accountInputs.Password2.text

	if name == "" or surname == "" or email == "" or password1 == "" or password2 == "" then
		accountFailed("Please fill in all fields.")
		return
	elseif password1 ~= password2 then 
		accountFailed("Please enter the same password in both password fields.")
		return
	end

	accountFailed()
	serverTried = true
	serverWaitTimer = serverWaitTime


	local failureReason = serv:CreateNewAccount(name, surname, email, password1)
	if failureReason then accountFailed(failureReason) end
end

function completeNewAccount() 								-- Finish creating the new account (once server has accepted)
	lovelyMoon.disableState("createAccount")
	lovelyMoon.enableState("startup")						-- Send student back to start to log in
end

function accountFailed(reason)
	errorReason = reason or ""

	serverTried = false
	serverWaitTimer = serverWaitTime
end

return state