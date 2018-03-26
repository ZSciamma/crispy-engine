Queue = Object:extend()

function Queue:new()				-- Called upon creation of a queue
	self.items = {}
	self.length = 0
end

function Queue:enqueue(item)			-- Add an item to the end of the queue
	table.insert(self.items, item)		-- Adds value at end of queue
	self.length = self.length + 1
	return true
end

function Queue:dequeue()				-- Remove the head value in the queue
	if self:isEmpty() then return 0 end
	local head = table.remove(self.items, 1)			-- First value removed
	self.length = self.length - 1
	return head
end

function Queue:peek()					-- Return the head value in the queue without dequeueing it
	if self:isEmpty() then return end
	return self.items[1]
end

function Queue:isEmpty()				-- Returns true if the length of the queue is 0, and false otherwise
	if self.length == 0 then
		return true
	else
		return false
	end
end

-- Queue:isFull() function unnecessary as tables in Lua are dynamic
