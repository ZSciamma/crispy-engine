-- This file allows communication between the student and the teacher. The teacher app manages communications between the students. This only works when the teacher app is running.
Server = Object:extend()

require "enet"

local teacher = {}
local events = {}
local className;
local Info = ""                  -- The information created by the student in order to create a new account or log in.
local creatingNewAccount = false        -- Are we creating a new account or joining an old one?

serverPeer = 0


-------------------- LOCAL FUNCTIONS:

local function split(peerMessage)
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

local function completeNewAccount() 
    creatingNewAccount = false
    CompleteNewAccount()
end

local function accountFailed(reason)
    creatingNewAccount = false
    AccountFailed(reason)
end

local function notifyStudentOfTournament(roundTime, qsPerMatch)
    addAlert("Your teacher has started a new tournament!", 500, 500)
    studentInfo.tournament = { RoundLength = RoundLength, QsPerMatch = qsPerMatch }
end

local function notifyStudentOfMatch(startDay, ratings1, ratings2, seed)
    addAlert("A new match is available!", 500, 500)
    print(startDay)
    print(ratings1)
    print(ratings2)
    print(seed)
    ratings1 = DecodeRating(ratings1)
    ratings2 = DecodeRating(ratings2)
    studentInfo.tournamentMatch = { StartDay = startDay, Ratings1 = ratings1, Ratings2 = ratings2, Seed = seed }
end

local function recordCurrentMatch(roundTime, qsPerMatch, startDay, ratings1, ratings2, seed)  -- Record essential information about the current match and tournament. Sent by the server when the student logs in.
    ratings1 = DecodeRating(ratings1)
    ratings2 = DecodeRating(ratings2)
    studentInfo.tournament = { RoundLength = roundTime, QsPerMatch = qsPerMatch }
    studentInfo.tournamentMatch = { StartDay = startDay, Ratings1 = ratings1, Ratings2 = ratings2, Seed = seed }
end

local function notifyStudentOfBye()                 -- Inform the student that they have been given a bye for their next match (odd number of players in tournament only)
    addAlert("You've received a bye! No student was available for your next match, so you get 3 tournament points.", 500, 500)
    studentInfo.tournamentMatch = nil
end

local function respondToMessage(event)   
    local messageTable = split(event.data)
    local first = messageTable[1]                   -- Find the description attached to the message
    command = first
    table.remove(messageTable, 1)                   -- Remove the description, leaving only the rest of the data
    local messageResponses = {                      -- List of messages that can be received from the teacher and their handling functions
        ["NewAccountAccept"] = function(peer) completeNewAccount() end,
        ["NewAccountReject"] = function(peer, reason) accountFailed(reason) end,
        ["LoginSuccess"] = function(peer, className, rating) CompleteLogin(className, rating) end,
        ["LoginFail"] = function(peer, reason) LoginFailed(reason) end,
        ["JoinClassSuccess"] = function(peer, className) JoinComplete(className) end,
        ["JoinClassFail"] = function(peer) end,
        ["LogoutSuccess"] = function(peer) LogoutComplete() end,
        ["NewTournament"] = function(peer, roundTime, qsPerMatch) notifyStudentOfTournament(roundTime, qsPerMatch) end,
        ["NewMatch"] = function(peer, roundTime, qsPerMatch, startDay, ratings1, ratings2, seed) notifyStudentOfMatch(roundTime, qsPerMatch, startDay, ratings1, ratings2, seed) end,
        ["CurrentMatch"] = function(peer, roundTime, startDay, ratings1, ratings2, seed) recordCurrentMatch(roundTime, startDay, ratings1, ratings2, seed) end,
        ["ByeReceived"] = function(peer) notifyStudentOfBye() end,

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

local function handleEvent(event)                
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




-------------------- GLOBAL FUNCTIONS:

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
    ---[[
    --if not foundClass then return end                 -- Eventually uncomment when debugging is done
    love.graphics.setColor(0, 0, 0)

    for i, event in ipairs(events) do
        love.graphics.print(event.peer:index().." says "..event.data, 10, 200 + 15 * i)
    end
    --]]
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

function Server:tryJoinClass(attemptedClassCode)
    self.on = true
    if not serverPeer then message() end
    serverPeer:send("StudentClassJoin" + attemptedClassCode)
    serv:update()
end

--[[
function Server:fetchTournamentInfo()                   -- Asks the central server for the student's next match. 
    if not self.setupComplete then return "incomplete" end
   
   serverPeer:send("NextGame")
end
--]]

function Server:tryLogout(rating)
    if not serverPeer then 
        setAlert("confirmation", "The server cannot be found. Would you like to log out anyway?")
    else
        serverPeer:send("StudentLogout" + rating)
    end
end

function Server:sendMatchResult(score)
    if not serverPeer then
        addAlert("The server seems to be unavailable. Please ensure you are connected to wifi.", 500, 500)
    else
        serverPeer:send("StudentMatchFinished" + score)
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


