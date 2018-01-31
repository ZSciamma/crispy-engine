-- This file allows communication between the student and the teacher. The teacher app manages communications between the students. This only works when the teacher app is running.
Server = Object:extend()

require "enet"

local teacher = {}
local events = {}
local className;

function Server:new()
    connected = false
    messageReceived = false
    self.on = false
    continue = true

    if not foundClass then return end  
    host = enet.host_create()
    
    server = host:connect(serverLoc)                --"172.28.198.21:63176")                            -- "192.168.0.12:60472")
                                                                            -- "172.28.198.21:63176"   
end


function Server:update(dt)
    if not foundClass then return end
    if continue == true then
        event = host:service(100)
        if event then
            table.insert(events, event)
            HandleEvent(event)
            if event.type == "receive" then
                messageReceived = true
                --continue = false
                
                --server:disconnect()
                --host:flush()
            end
        end
    end
end


function Server:draw()
    --if not foundClass then return end                 -- Eventually uncomment when debugging is done
    love.graphics.setColor(0, 0, 0)

    if StudentID then love.graphics.print("StudentID: "..StudentID, love.graphics.getWidth()/2 - 30, 50) end

    if connected == true then
        love.graphics.print("Connected to "..host:get_socket_address(), 5, 5)
    end
    
    if messageReceived == true then
        love.graphics.print("Got message: ", 5, 30)
    end

    for i, event in ipairs(events) do
        love.graphics.print(event.peer:index().." says "..event.data, 10, 200 + 15 * i)
    end
end


function Server:reachClass(classLocation)
    host = enet.host_create()
    server = host:connect(classLocation)
    if server then 
        serv.on = true
        return true 
    end
end

function AcceptID(newID)
    if StudentID ~= "" then return false end
    StudentID = newID
    joinComplete()
    return true
end

function HandleEvent(event)                 -- FIX THIS: handles all events
    if event.type == "connect" then
        teacher = event.peer
        if StudentID == "" then 
            event.peer:send("NewStudent" + myForename + mySurname + myEmail + myPassword + attemptedClassCode)
        else
            event.peer:send("StudentID" + StudentID)
        end
    elseif event.type == "receive" then
        respondToMessage(event)
        --[[
        local messageReceived = event.data
        local identifier = ""
        local messageTable = string.gmatch(messageReceived, "[,]%S")
        identifier = messageTable[1]
        for i, mess in ipairs(messageTable) do
        end
        --]]
    end
end

function respondToMessage(event)   
    local messageTable = split(event.data)
    local first = messageTable[1]                   -- Find the description attached to the message
    table.remove(messageTable, 1)                   -- Remove the description, leaving only the rest of the data
    local messageResponses = {                      -- List of messages that can be received from the teacher and their handling functions
        ["NewStudentAccept"] = function(peer, newID, TeacherForename, TeacherSurname) AcceptID(newID, TeacherForename, TeacherSurname) end, 
        ["NewStudentReject"] = function(peer, reason) RejectNewStudent(reason) end, 
        ["FailedToJoinClass"] = function(peer) joinedClass = false; foundClass = false; ClassName = "" end,
        ["WelcomeToClass"] = function(peer, newStudentID, TeacherForename, TeacherSurname) AcceptID(newStudentID, TeacherForename, TeacherSurname) end --StudentID = newStudentID end
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

function RejectNewStudent(reason)
    -- Tell the student their email is invalid
end

