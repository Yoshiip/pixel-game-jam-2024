vector = require "utils.vector"
require "projectile"
require "collision"

Duck = {}
Duck.__index = Duck

local duckTexture = love.graphics.newImage("resources/textures/duck.png")
local duck_water_mask_texture = love.graphics.newImage("resources/textures/duck_water_mask.png")

local shoot_max_timer = 0.3
local friction = 0.085
local acceleration = 0.075

-- ANIMATIONS
local anim_speed = 1 / 12
local anim_frame_size = vector(32, 32)

-- IDLE
local idle_origin = vector(0, 0)
local idle_frame_count = 8

-- SHOOT
local shoot_origin = vector(256, 0)
local shoot_frame_count = 8

-- WALK
local walk_origin = vector(512, 0)
local walk_frame_count = 4

function Duck:new()
    local self = setmetatable({}, Duck)
    self.__index = self
    self.pos = vector(32, 32)
    self.vel = vector(0, 0)
    self.trail = {
        vector(0, 0)
    }
    self.max_health = 5
    self.health = self.max_health
    self.anim_frame = 0
    self.in_water = true
    self.zone_cleared = false
    self.shoot_timer = 0.3
    self.anim_timer = 0.3
    self.flip = false
    self.shooting = false
    self.collision = Collision:new(self, "player", self.pos, vector(20, 20))
    table.insert(Collisions, self.collision)
    return self
end

function Duck:getState()
    local anim = "idle"
    if self.shooting then
        anim = "shoot"
        if self.anim_frame >= shoot_frame_count then
            self.shooting = false
        end
    elseif self.vel:len() > 1 then
        anim = "walk"
    end
    return anim
end

function Duck:draw()
    if self.vel.x < 0 then
        self.flip = true
    elseif self.vel.x > 0 then
        self.flip = false
    end
    local sx = self.flip and -1 or 1

    local state = self:getState()
    local anim_frame_count = idle_frame_count
    local origin = vector(0, 0)
    if state == "idle" then
        origin = idle_origin
        anim_frame_count = idle_frame_count
    elseif state == "shoot" then
        origin = shoot_origin
        anim_frame_count = shoot_frame_count
    elseif state == "walk" then
        origin = walk_origin
        anim_frame_count = walk_frame_count
    end
    self.anim_frame = self.anim_frame % anim_frame_count
    local duckQuad = love.graphics.newQuad(
        origin.x + (anim_frame_size.x * self.anim_frame),
        origin.y,
        anim_frame_size.x,
        anim_frame_size.y,
        duckTexture:getDimensions()
    )
    -- local duckQuad = love.graphics.newQuad(0, 0, 16, 16, Atlas:getDimensions())

    local x, y = self.pos:unpackInt()
    love.graphics.draw(duckTexture, duckQuad, x, y, 0, sx, 1, 16, 16)
    if self.in_water then

    end
    love.graphics.draw(duck_water_mask_texture, x, y + 16, 0, 1, 1, 9, 5)
end

local trailClock = 0.1

function Duck:damage(amt)
    self.health = self.health - amt
    SpawnDroplet()
end

function Duck:shoot()
    local vel = GameMousePos - self.pos
    local vel = vel:normalized()
    self.shooting = true
    self.anim_frame = 0
    self.vel = vector(0, 0)
    print(2 + UI:CountElementWorking("strength"))
    local projectile = Projectile:new(
        vector(self.pos.x, self.pos.y),
        vel,
        false,
        "player",
        2 + UI:CountElementWorking("strength")
    )
    table.insert(Projectiles, projectile)
end

local function loopPlayerPosition(self, delta)
    local spawns = {
        left = -16,
        right = GameResolution.x + 16,
        up = -24,
        down = GameResolution.y + 4,
    }


    self.pos = self.pos + self.vel * delta
    if self.pos.x < -16 then
        self.pos.x = spawns.right
        return true
    end
    if self.pos.y < -32 then
        self.pos.y = spawns.down
        return true
    end
    if self.pos.x > GameResolution.x + 16 then
        self.pos.x = spawns.left
        return true
    end
    if self.pos.y > GameResolution.y + 4 then
        self.pos.y = spawns.up
        return true
    end
    return false
end

function Duck:update()
    local input = vector(0, 0)
    local delta = love.timer.getDelta()

    local buttonsWorking = UI:getButtonsWorking()


    local keys_pressed = {}
    for key, hotkeys in pairs(Bindings) do
        for i, hotkey in ipairs(hotkeys) do
            -- if string.sub(hotkey, 1, 5) == "mouse" then
            --     if love.mouse.isDown(hotkey) then
            --         keys_pressed[key] = true
            --     end
            -- elseif love.keyboard.isDown(hotkey) then
            --     keys_pressed[key] = true
            -- end
        end
    end
    if IsKeyPressed("move_left") == true and buttonsWorking["move_left"] == true then
        input.x = input.x - 1
    end
    if IsKeyPressed("move_right") and buttonsWorking["move_right"] == true then
        input.x = input.x + 1
    end
    if IsKeyPressed("move_up") and buttonsWorking["move_up"] == true then
        input.y = input.y - 1
    end
    if IsKeyPressed("move_down") and buttonsWorking["move_down"] == true then
        input.y = input.y + 1
    end


    self.shoot_timer = self.shoot_timer - delta

    if IsKeyPressed("shoot") and self.shoot_timer < 0.0 then
        self:shoot()
        self.shoot_timer = shoot_max_timer
    end

    input = input:normalized()

    if loopPlayerPosition(self, delta) and self.zone_cleared then
        PlayerExited()
    end


    if input:len() > 0 then
        self.vel = lerp(self.vel, input:normalized() * 50, acceleration)
    else
        self.vel = lerp(self.vel, vector(0, 0), friction)
    end

    -- ANIMATIONS
    self.anim_timer = self.anim_timer - delta
    if self.anim_timer < 0.0 then
        self.anim_frame = self.anim_frame + 1
        self.anim_timer = anim_speed
    end



    trailClock = trailClock - delta
    if trailClock < 0 then
        trailClock = 0.1
        if (#self.trail > 10) then
            table.remove(self.trail, 1)
        end
        table.insert(self.trail, vector(self.pos.x, self.pos.y))
    end

    self.collision.pos = self.pos - (self.collision.size / 2)
end

function lerp(a, b, t)
    return a + (b - a) * t
end
