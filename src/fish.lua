vector = require "utils.vector"
require "projectile"
require 'collision'

Fish = {}
Fish.__index = Fish


function Fish:new(duck, pos, i)
    local self = setmetatable({}, Fish)
    self.pos = pos
    self.max_health = 3
    self.health = self.max_health
    self.i = i
    self.shoot_timer = 0.4

    self.duck = duck
    self.collision = Collision:new(self, "enemy", self.pos, vector(16, 16))
    table.insert(Collisions, self.collision)
    return self
end

local fishQuad = love.graphics.newQuad(0, 0, 16, 16, Atlas:getDimensions())

function Fish:draw()
    love.graphics.draw(Atlas, fishQuad, math.floor(self.pos.x), math.floor(self.pos.y), 0, 1, 1, 8, 8)
end

function Fish:destroy()
    table.remove(Collisions, indexOf(Collisions, self.collision))
    table.remove(Fishes, indexOf(Fishes, self))
end

function Fish:shoot()
    local vel = Player.pos - self.pos
    local vel = vel:normalized()
    local projectile = Projectile:new(
        vector(self.pos.x, self.pos.y),
        vel,
        true
    )
    table.insert(Projectiles, projectile)
end

function Fish:damage(amt)
    self.health = self.health - amt
    if self.health <= 0 then
        self:destroy()
    end
end

function Fish:update()
    local delta = love.timer.getDelta()
    local speed = 0.1 * delta

    self.shoot_timer = self.shoot_timer - delta
    if self.shoot_timer < 0.0 then
        self:shoot()
        self.shoot_timer = math.random(1.0, 2.0)
    end


    local point = self.duck.pos
    if point == nil then
        return
    end

    self.pos.x = self.pos.x + (point.x - self.pos.x) * speed
    self.pos.y = self.pos.y + (point.y - self.pos.y) * speed

    self.collision.pos = self.pos - vector(8, 8)
end
