-- This file allows communication between the student and the teacher. The teacher app manages communications between the students. This only works when the teacher app is running.
Server = Object:extend()

require "enet"

local teacher = {}
local className;

function Server:new()
    connected = false
    messageReceived = false
    self.on = false
    continue = true

    if not foundClass then return end  
    host = enet.host_create()
    
    server = host:connect(loc)                --"172.28.198.21:63176")                            -- "192.168.0.12:60472")
                                                                            -- "172.28.198.21:63176"   
end


function Server:update(dt)
    if not foundClass then return end
    if continue == true then
        event = host:service(100)
        if event then
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
    if not foundClass then return end
    if connected == true then
        love.graphics.print("Connected to "..host:get_socket_address(), 5, 5)
    end
    
    if messageReceived == true then
        love.graphics.print("Got message: ", 5, 30)
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

function AcceptID(newID, TeacherForename, TeacherSurname)
    if StudentID ~= "" then return false end
    StudentID = newID
    TeacherID = TeacherForename.." "..TeacherSurname
    joinComplete()
    return true
end

function HandleEvent(event)                 -- FIX THIS: handles all events
    if event.type == "connect" then
        teacher = event.peer
        if not joinedClass then 
            event.peer:send("JoinRequest"..", "..forename..", "..surname..", "..email..", "..ClassName)
        else
            event.peer:send("StudentID, "..StudentID)
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
        ["StudentIDAccepted"] = function(newID, TeacherForename, TeacherSurname) AcceptID(newID, TeacherForename, TeacherSurname) end,  
        ["FailedToJoinClass"] = function() joinedClass = false; foundClass = false; ClassName = "" end
    }
    if messageResponses[first] then messageResponses[first](event.peer, unpack(messageTable))end
end

