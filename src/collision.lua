vector = require "utils.vector"

DebugCollision = false

Collision = {}
Collision.__index = Collision

function Collision:new(owner, type, pos, size)
    local self = setmetatable({}, Collision)
    self.owner = owner
    self.type = type
    self.pos = pos
    self.size = size
    return self
end

function Collision:draw()
    if DebugCollision then
        love.graphics.setColor(0.2, 0.4, 0.9, 0.3)
        love.graphics.rectangle("fill", self.pos.x, self.pos.y, self.size.x, self.size.y)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function Collision:checkRectangle(other)
    if (
            self.pos.x + self.size.x >= other.pos.x and
            self.pos.x <= other.pos.x + other.size.x and
            self.pos.y + self.size.y >= other.pos.y and
            self.pos.y <= other.pos.y + other.size.y) then
        return true
    end
    return false
end

function Collision:checkPoint(vec)
    if vec == nil then
        return false
    end
    if (
            vec.x >= self.pos.x and
            vec.x <= self.pos.x + self.size.x and
            vec.y >= self.pos.y and
            vec.y <= self.pos.y + self.size.y) then
        return true
    end
    return false
end
