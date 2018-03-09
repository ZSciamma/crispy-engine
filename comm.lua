-- This file allows communication between the student and the teacher. The teacher app manages communications between the students. This only works when the teacher app is running.
Server = Object:extend()

require "enet"

local teacher = {}
local events = {}
local className;
local Info = ""                  -- The information created by the student in order to create a new account or log in.
local creatingNewAccount = false        -- Are we creating a new account or joining an old one?

serverPeer = 0

function Server:new()         
    self.on = false                                                  
end

function Server:update(dt)
    event = host:service(2)
    if event then
        table.insert(events, event)
        handleEvent(event)
    end
end


function Server:draw()
    --if not foundClass then return end                 -- Eventually uncomment when debugging is done
    love.graphics.setColor(0, 0, 0)

    for i, event in ipairs(events) do
        love.graphics.print(event.peer:index().." says "..event.data, 10, 200 + 15 * i)
    end
end

function Server:connect()
    host = enet.host_create()
    self.server = host:connect(serverLoc)
end

function Server:CreateNewAccount(name, surname, email, password)
    Info = name + surname + email + password
    creatingNewAccount = true

    if self.server then 
        serverPeer:send("NewStudentAccount" + Info)
    else
        self:connect() 
    end

    self.on = true
end

function Server:LoginToAccount(email, password)
    Info = email + password
    creatingNewAccount = false

    if self.server then
        serverPeer:send("StudentLogin" + Info)
    else
        self:connect()
    end

    self.on = true
end

--[[
function Server:reachClass()
    if self.setupComplete then return end
    host = enet.host_create()
    self.server = host:connect(serverLoc)
    self.setupComplete = true
    if self.server then 
        self.on = true
        return true 
    end
end
--]]

function Server:tryJoinClass(attemptedClassCode)
    self.on = true
    if not serverPeer then message() end
    serverPeer:send("StudentClassJoin" + attemptedClassCode)
    serv:update()
end

function Server:fetchTournamentInfo()                   -- Asks the central server for the student's next match. 
    if not self.setupComplete then return "incomplete" end
   
   serverPeer:send("NextGame")
end

function Server:tryLogout(rating)
    if not serverPeer then 
        setAlert("confirmation", "The server cannot be found. Would you like to log out anyway?")
    else
        serverPeer:send("StudentLogout" + rating)
    end
end


function SendInfo(peer, message, isStudent, ID)     -- Sends outgoing information. Also checks is peer is still online. NOT USED FOR NEW STUDENTS
    local user = IdentifyPeer(peer)
    if user then                                    -- Checks if peer is online. Clearly only valid if user is not new.
        peer:send(message)
    else                                            -- If user is not new and not online, store message for later
        listEvent(message, isStudent, ID)
    end
end

function handleEvent(event)                
    if event.type == "connect" then
        serverPeer = event.peer
        if creatingNewAccount then
            serverPeer:send("NewStudentAccount" + Info)
        else
            serverPeer:send("StudentLogin" + Info)
        end
    elseif event.type == "receive" then
        respondToMessage(event)
    end
end

function respondToMessage(event)   
    local messageTable = split(event.data)
    local first = messageTable[1]                   -- Find the description attached to the message
    command = first
    table.remove(messageTable, 1)                   -- Remove the description, leaving only the rest of the data
    local messageResponses = {                      -- List of messages that can be received from the teacher and their handling functions
        ["NewAccountAccept"] = function(peer) CompleteNewAccount() end,
        ["NewAccountReject"] = function(peer, reason) AccountFailed(reason) end,
        ["LoginSuccess"] = function(peer, className, rating) completeLogin(className, rating) end,
        ["LoginFail"] = function(peer, reason) loginFailed(reason) end,
        ["JoinClassSuccess"] = function(peer, className) joinComplete(className) end,
        ["JoinClassFail"] = function(peer) end,
        ["LogoutSuccess"] = function(peer) logoutComplete() end,
        ["NewTournament"] = function(peer) notifyStudentOfTournament() end,

        --["NewStudentAccept"] = function(peer, newID, className) AcceptID(newID, className) end, 
        --["NewStudentReject"] = function(peer, reason) RejectNewStudent(reason) end, 
        --["FailedToJoinClass"] = function(peer) studentInfo.joinedClass = false; foundClass = false; studentInfo.className = "" end,
        --["WelcomeToClass"] = function(peer, newStudentID, TeacherForename, TeacherSurname) AcceptID(newStudentID, TeacherForename, TeacherSurname) end, --StudentID = newStudentID end
        --["WelcomeBackStudent"] = function(peer) end,
        --["NoCurrentTournament"] = function(peer) NoTournament() end,
        --["NoNewGames"] = function(peer) NoMatches() end,
        --["NextGame"] = function(peer, level1, level2) ReceiveMatchInfo(level1, level2) end
    }
    if messageResponses[first] then messageResponses[first](event.peer, unpack(messageTable))end
end

function split(peerMessage)
    local messageTable = {}
    peerMessage = peerMessage..".....9"
    local length = #peerMessage
    local dots = 0
    local last = 1
    for i = 1,length do
        local c = string.sub(peerMessage, i, i)
        if c == '.' then
            dots = dots + 1
        else
            if dots >= 5 then
                local word = string.sub(peerMessage, last, i - 6)
                if word == "0" then word = "" end                     -- Account for the server sending blank info
                last = i 
                table.insert(messageTable, word)
            end
            dots = 0
        end
    end
    return messageTable
end

function CompleteNewAccount()
    creatingNewAccount = false
    completeNewAccount()
end

function AccountFailed(reason)
    creatingNewAccount = false
    accountFailed(reason)
end

function notifyStudentOfTournament()
    addAlert("Your teacher has started a new tournament!", 500, 500)
end

--[[
function AcceptID(newID, className)
    if studentInfo.StudentID ~= "" then return false end
    studentInfo.StudentID = newID
    studentInfo.className = className
    joinComplete()
    return true
end

function RejectNewStudent(reason)
    -- Tell the student their email is invalid
end

--]]
