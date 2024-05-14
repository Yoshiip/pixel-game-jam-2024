vector = require "utils.vector"

Projectile = {}
Projectile.__index = Projectile

-- ANIMATIONS
local anim_speed = 1 / 12
local anim_frame_size = vector(16, 16)
local anim_frame_count = 8

-- DEFAULT
local player_projectile_origin = vector(0, 16)
local enemy_projectile_origin = vector(0, 32)
local ball_projectile_origin = vector(128, 16)
local watermelon_projectile_origin = vector(128, 32)

function Projectile:new(pos, vel, from_enemy, type)
    local self = setmetatable({}, Projectile)
    self.pos = pos
    self.vel = vel
    self.anim_frame = 0
    self.anim_timer = 1 / 12
    self.from_enemy = from_enemy
    self.height = 0 -- used for shadow (see main.lua)
    if self.type == "watermelon" or self.type == "ball" then
        self.height = 8
    end
    self.collision = Collision:new(self, "projectile", self.pos, vector(10, 10))
    table.insert(Collisions, self.collision)
    return self
end

local enemy_projectile_quad = love.graphics.newQuad(0, 32, 16, 16, Atlas:getDimensions())
local player_projectile_quad = love.graphics.newQuad(0, 16, 16, 16, Atlas:getDimensions())

function Projectile:draw()
    local quad = player_projectile_quad
    if self.from_enemy then
        quad = enemy_projectile_quad
    end
    local origin = vector(0, 0)
    if self.type == "watermelon" then
        origin = watermelon_projectile_origin
    elseif self.type == "ball" then
        origin = ball_projectile_origin
    elseif self.from_enemy then
        origin = enemy_projectile_origin
    else
        origin = player_projectile_origin
    end
    self.anim_frame = self.anim_frame % anim_frame_count
    local projectile_quad = love.graphics.newQuad(
        origin.x + (anim_frame_size.x * self.anim_frame),
        origin.y,
        anim_frame_size.x,
        anim_frame_size.y,
        Atlas:getDimensions()
    )
    love.graphics.draw(
        Atlas,
        projectile_quad,
        math.floor(self.pos.x + 0.5),
        math.floor(self.pos.y + 0.5),
        0, 1, 1, 8, 8)
end

function Projectile:destroy()
    table.remove(Collisions, indexOf(Collisions, self.collision))
    table.remove(Projectiles, indexOf(Projectiles, self))
end

function Projectile:update()
    local delta = love.timer.getDelta()
    local speed = 100 * delta
    self.pos.x = self.pos.x + self.vel.x * speed
    self.pos.y = self.pos.y + self.vel.y * speed

    self.anim_timer = self.anim_timer - delta
    if self.anim_timer < 0.0 then
        self.anim_frame = self.anim_frame + 1
        self.anim_timer = anim_speed
    end

    if (
            self.pos.x < -16 or
            self.pos.x > Resolution.x + 16 or
            self.pos.y < -16 or
            self.pos.y > Resolution.y + 16
        ) then
        self:destroy()
    end

    self.collision.pos = self.pos - vector(5, 5)

    -- check collisions

    for i = #Collisions, 1, -1 do
        local coll = Collisions[i]
        local colliding = Collision.checkRectangle(self.collision, coll)
        if (
                (self.from_enemy and colliding and coll.type == "player") or
                (not self.from_enemy and colliding and coll.type == "enemy")
            ) then
            coll.owner:damage(1)
            self:destroy()
        end
    end
end
