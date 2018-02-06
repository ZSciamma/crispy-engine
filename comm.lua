-- This file allows communication between the student and the teacher. The teacher app manages communications between the students. This only works when the teacher app is running.
Server = Object:extend()

require "enet"

local teacher = {}
local events = {}
local className;

serverPeer = 0

function Server:new()
    self.setupComplete = false
    self.on = false

    if not foundClass then return end  
    host = enet.host_create()
    
    self.server = host:connect(studentInfo.serverLoc)                --"172.28.198.21:63176")                            -- "192.168.0.12:60472")
    self.setupComplete = true
                                                                            -- "172.28.198.21:63176"   
end

function Server:update(dt)
    event = host:service(100)
    if event then
        table.insert(events, event)
        HandleEvent(event)
    end
end


function Server:draw()
    --if not foundClass then return end                 -- Eventually uncomment when debugging is done
    love.graphics.setColor(0, 0, 0)

    if StudentID then love.graphics.print("StudentID: "..studentInfo.StudentID, love.graphics.getWidth()/2 - 30, 50) end

    for i, event in ipairs(events) do
        love.graphics.print(event.peer:index().." says "..event.data, 10, 200 + 15 * i)
    end
end


function Server:reachClass()
    if self.setupComplete then return end
    host = enet.host_create()
    self.server = host:connect(studentInfo.serverLoc)
    self.setupComplete = true
    if self.server then 
        serv.on = true
        return true 
    end
end

function Server:fetchTournamentInfo()                   -- Asks the central server for the student's next match. 
    if not self.setupComplete then return "incomplete" end
   
   serverPeer:send("NextMatch")
end


function SendInfo(peer, message, isStudent, ID)     -- Sends outgoing information. Also checks is peer is still online. NOT USED FOR NEW STUDENTS
    local user = IdentifyPeer(peer)
    if user then                                    -- Checks if peer is online. Clearly only valid if user is not new.
        peer:send(message)
    else                                            -- If user is not new and not online, store message for later
        listEvent(message, isStudent, ID)
    end
end

function HandleEvent(event)                
    if event.type == "connect" then
        serverPeer = event.peer
        if studentInfo.StudentID == "" then 
            event.peer:send("NewStudent" + studentInfo.myForename + studentInfo.mySurname + studentInfo.myEmail + studentInfo.myPassword + attemptedClassCode)
        else
            event.peer:send("OfferStudentID" + studentInfo.StudentID + studentInfo.myPassword)
        end
    elseif event.type == "receive" then
        respondToMessage(event)
    end
end

function respondToMessage(event)   
    local messageTable = split(event.data)
    local first = messageTable[1]                   -- Find the description attached to the message
    table.remove(messageTable, 1)                   -- Remove the description, leaving only the rest of the data
    local messageResponses = {                      -- List of messages that can be received from the teacher and their handling functions
        ["NewStudentAccept"] = function(peer, newID, className) AcceptID(newID, className) end, 
        ["NewStudentReject"] = function(peer, reason) RejectNewStudent(reason) end, 
        ["FailedToJoinClass"] = function(peer) studentInfo.joinedClass = false; foundClass = false; studentInfo.className = "" end,
        ["WelcomeToClass"] = function(peer, newStudentID, TeacherForename, TeacherSurname) AcceptID(newStudentID, TeacherForename, TeacherSurname) end, --StudentID = newStudentID end
        ["WelcomeBackStudent"] = function(peer) end,
        ["NoCurrentTournament"] = function(peer) NoTournament() end,
        ["NoNewMatches"] = function(peer) NoMatches() end,
        ["NextMatch"] = function(peer, studentsInfo) ReceiveMatchInfo(studentsInfo) end
    }
    if messageResponses[first] then messageResponses[first](event.peer, unpack(messageTable))end
end

function split(peerMessage)
    local messageTable = {}
    for word in peerMessage:gmatch("[^%s,]+") do         -- Possibly write a better expression - try some basic email regex?
        table.insert(messageTable, word)
    end
    return messageTable
end

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

