vector = require "utils.vector"
require "projectile"
require "collision"


Droplet = {}
Droplet.__index = Droplet

local drop_max_time = 0.4

function Droplet:new(pos)
    local self = setmetatable({}, Droplet)
    self.pos = pos
    self.vel = vector(love.math.random(-0.2, 0.2), 3)
    self.lifetime = love.math.random(3.0, 5.0)
    self.drops = {}
    self.speed = 30
    self.drop_timer = drop_max_time
    self:addDrop()

    self.collision = Collision:new(self, "droplet", self.pos, vector(80, 80))
    table.insert(Collisions, self.collision)
    return self
end

function Droplet:draw()
    for i, drop in ipairs(self.drops) do
        love.graphics.setColor(1, 1, 1, drop.lifetime / 5.0)
        love.graphics.circle("fill", drop.pos.x, drop.pos.y, drop.size)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function Droplet:destroy()
    table.remove(Collisions, indexOf(Collisions, self.collision))
    table.remove(Droplets, indexOf(Droplets, self))
end

function Droplet:addDrop()
    table.insert(self.drops, {
        pos = vector(self.pos.x, self.pos.y),
        size = love.math.random(20, 40),
        lifetime = self.lifetime
    })
end

function Droplet:update()
    local delta = love.timer.getDelta()
    self.drop_timer = self.drop_timer - delta
    if self.drop_timer < 0.0 then
        self:addDrop()
        self.drop_timer = drop_max_time
    end


    self.lifetime = self.lifetime - delta
    if self.lifetime < 0.0 then
        self:destroy()
    end

    for i, drop in ipairs(self.drops) do
        drop.lifetime = drop.lifetime - delta
    end

    self.pos.x = self.pos.x + (self.vel.x * self.speed * delta)
    self.pos.y = self.pos.y + (self.vel.y * self.speed * delta)

    -- check collisions

    self.collision.pos = self.pos - (self.collision.size / 2)

    for i = #Collisions, 1, -1 do
        local coll = Collisions[i]
        local colliding = Collision.checkRectangle(self.collision, coll)
        if (colliding and coll.type == "button") then
            coll.owner:damage(1)
            self:destroy()
        end
    end
end
