vector = require "utils.vector"
require "projectile"
require 'collision'

Fish = {}
Fish.__index = Fish

Enemies = {
    {
        min_level = 1,
        max_health = 3,
        speed = 15,
        animation_origin = vector(0, 0),
        animation_frame_count = 2
    },
    {
        min_level = 2,
        max_health = 5,
        speed = 20,
        animation_origin = vector(32, 0),
        animation_frame_count = 2
    },
    {
        min_level = 3,
        max_health = 8,
        speed = 25,
        animation_origin = vector(64, 0),
        animation_frame_count = 2
    },
    {
        min_level = 4,
        max_health = 15,
        speed = 35,
        animation_origin = vector(96, 0),
        animation_frame_count = 2
    },
}

-- ANIMATIONS
local anim_speed = 1 / 12
local anim_frame_size = vector(32, 32)



function Fish:new(id, pos)
    local self = setmetatable({}, Fish)
    self.pos = pos
    self.id = id
    self.enemy_data = Enemies[id]
    self.max_health = self.enemy_data.max_health
    self.health = self.max_health
    self.ia_mode = love.math.random(0, 1) -- 0 = random point, 1 = player position
    self.ia_cycle = 10.0
    self.shoot_timer = 0.4
    self.target_pos = vector(
        love.math.random(32, GameResolution.x - 32),
        love.math.random(32, GameResolution.y - 32)
    )

    self.collision = Collision:new(self, "enemy", self.pos, vector(16, 16))
    table.insert(Collisions, self.collision)
    return self
end

local fishQuad = love.graphics.newQuad(0, 0, 16, 16, Atlas:getDimensions())

function Fish:draw()
    local origin = self.enemy_data.animation_origin
    local quad = love.graphics.newQuad(origin.x, origin.y, 16, 16, Atlas:getDimensions())
    love.graphics.draw(Atlas, quad, math.floor(self.pos.x), math.floor(self.pos.y), 0, 1, 1, 8, 8)
end

function Fish:destroy()
    table.remove(Collisions, indexOf(Collisions, self.collision))
    table.remove(Fishes, indexOf(Fishes, self))
end

function Fish:shoot()
    local vel = Player.pos - self.pos + vector(love.math.random(-20, 20), love.math.random(-20, 20))
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
    local speed = self.enemy_data.speed

    self.shoot_timer = self.shoot_timer - delta
    if self.shoot_timer < 0.0 then
        self:shoot()
        self.shoot_timer = math.random(1.0, 2.0)
    end
    self.ia_cycle = self.ia_cycle - delta
    if self.ia_cycle < 0.0 then
        if self.ia_mode == 0 then
            self.ia_mode = 1
        else
            self.ia_mode = 0
        end
        self.ia_cycle = love.math.random(5, 15)
    end


    if self.ia_mode == 0 then
        if self.pos:dist(self.target_pos) < 4.0 then
            self.target_pos = vector(
                love.math.random(32, GameResolution.x - 32),
                love.math.random(32, GameResolution.y - 32)
            )
        end
    elseif self.ia_mode == 1 then
        self.target_pos = Player.pos
        if self.target_pos == nil then
            return
        end
    end

    local dir = self.target_pos - self.pos
    dir = dir:normalized()

    self.pos = self.pos + dir * (speed * delta)

    self.collision.pos = self.pos - vector(8, 8)
end
