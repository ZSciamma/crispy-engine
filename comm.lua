-- This file allows communication between the student and the teacher. The teacher app manages communications between the students. This only works when the teacher app is running.
Server = Object:extend()

require "enet"

function Server:new()
    if not foundClass then return end

    connected = false
    messageReceived = false
    
    host = enet.host_create()
    
    server = host:connect("192.168.0.12:60472")
    
    continue = true
end


function Server:update(dt)
    if not foundClass then return end
    if continue == true then
        event = host:service(100)
        if event then
            HandleEvent()
            if event.type == "connect" then
                connected = true
                event.peer:send(surname..", "..forename..", "..email)
            elseif event.type == "receive" then
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

function HandleEvent(event)                 -- FIX THIS: handles all events
    if event.type == "connect" then
        if not joinedClass then end
    end
end


function Server:reachClass(classLocation)
    host = enet.host_create()
    server = host:connect(classLocation)
    return true
end

