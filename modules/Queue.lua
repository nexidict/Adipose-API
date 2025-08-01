---@class Queue
---@field data table
---@field head number
---@field tail number
local Queue = {}
Queue.__index = Queue

---@return Queue
function Queue:new()
    local obj = setmetatable({
        data = {},
        head = 1,
        tail = 0,
    }, self)

    return obj
end

function Queue:push(value)
    self.tail = self.tail + 1
    self.data[self.tail] = value
end

function Queue:pop()
    if self.head > self.tail then
        error("Queue is empty")
    end

    local value = self.data[self.head]
    self.data[self.head] = nil
    self.head = self.head + 1
    return value
end

function Queue:isEmpty()
    return self.head > self.tail
end

return Queue

