local state = {}

local accountInputs = {
	Name = textInput("Name", 400, 150, 300, 25),
	Surname = textInput("Surname", 400, 200, 300, 25),
	Email = textInput("Email", 400, 250, 300, 25),
	Password1 = textInput("Password", 400, 300, 300, 25, true),
	Password2 = textInput("Re-Enter Password", 400, 350, 300, 25, true)
}

local backB = sButton("Back", 100, 100, 100, 50, "createAccount", "startup")
local enterB = sButton("Create Account", 400, 450, 300, 75, "createAccount", function() ValidateNewAccount() end)

local errorReason = ""					-- Why the user's account creation failed
local serverWaitTime = 5				-- Time after which the server is declared unavaliable
local serverWaitTimer = serverWaitTime
local serverTried = false				-- Are we trying to connect to the server?


-------------------- LOCAL FUNCTIONS:

local function disableButtons()
	backB:disable()
	enterB:disable()
end

local function enableButtons()
	backB:enable()
	enterB:enable()
end


-------------------- GLOBAL FUNCTIONS:

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
	enableButtons()
end


function state:disable()
	for i,input in pairs(accountInputs) do
		input:disable()
	end
	AccountFailed()						-- Reset errors and timers
	disableButtons()
end


function state:update(dt)
	for i,input in pairs(accountInputs) do
		input:update(dt)
	end

	if serverTried then
		if serverWaitTimer <= 0 then
			serverTried = false
			AccountFailed("The server is currently unavaliable. Please try again later.")
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

function state:textinput(text)
	for i,input in pairs(accountInputs) do
		input:textinput(text)
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

function ValidateNewAccount() 						-- Ask the server to create the new account
	local name = accountInputs.Name.text
	local surname = accountInputs.Surname.text
	local email = accountInputs.Email.text
	local password1 = accountInputs.Password1.text
	local password2 = accountInputs.Password2.text

	-- Ensure all fields are full :
	if name == "" or surname == "" or email == "" or password1 == "" or password2 == "" then
		AccountFailed("Please fill in all fields.")
		return
	elseif password1 ~= password2 then
		AccountFailed("Please enter the same password in both password fields.")
		return
	end

	-- Deny any use of the delimiter:
	for i,input in pairs(accountInputs) do
		if input:checkDelimiter() then
			addAlert("Please enter fewer exotic characters.", 500, 500)
			return
		end
	end

	-- Password Strength:
	local strongPassword = accountInputs.Password1:passwordStrength()
	if not strongPassword then
		addAlert("Please use a stronger password.", 500, 500)
		return
	end

	AccountFailed()
	disableButtons()

	serverTried = true
	serverWaitTimer = serverWaitTime

	local failureReason = serv:CreateNewAccount(name, surname, email, password1)
	if failureReason then AccountFailed(failureReason) end
end

function CompleteNewAccount() 								-- Finish creating the new account (once server has accepted)
	addAlert("You successfully created an account!", 500, 500)
	lovelyMoon.disableState("createAccount")
	lovelyMoon.enableState("startup")						-- Send student back to start to log in
end

function AccountFailed(reason)
	enableButtons()
	if reason then addAlert(reason, 500, 500) end
	--errorReason = reason or ""

	serverTried = false
	serverWaitTimer = serverWaitTime
end

return state
