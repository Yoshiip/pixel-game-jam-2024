require "ui_element"
require "collision"
vector = require "utils.vector"

Joystick = {}
Joystick.__index = Joystick
setmetatable(Joystick, { __index = UIElement })

function Joystick:new(id, pos, size)
    local self = setmetatable(UIElement:new(id, pos, vector(0, 0), size), Joystick)
    self.max_health = 5
    self.health = self.max_health
    self.trauma = 0
    self.disabled = false
    self.hovered = false
    self.grab_valid = false
    self.grabbed = false
    self.grab_base_position = vector(0, 0)
    return self
end

local inertia = vector(0, 0)
local mouse_delta = vector(0, 0)



local max_length = 640

function Joystick:draw()
    local joystick_quad = love.graphics.newQuad(0, 128, 32, 32, UIImage:getDimensions())
    local joystick_base_quad = love.graphics.newQuad(32, 128, 32, 32, UIImage:getDimensions())
    inertia = inertia - (mouse_delta - vector(love.mouse.getX(), love.mouse.getY()))
    inertia = inertia * 0.8
    inertia = inertia:normalized() * math.sqrt(math.min(inertia:len(), max_length))

    love.graphics.draw(UIImage, joystick_base_quad, self.pos.x, self.pos.y, 0, 1, 1, 16, 16)
    love.graphics.draw(UIImage, joystick_quad, math.floor(self.pos.x + inertia.x + 0.5),
        math.floor(self.pos.y + inertia.y + 0.5), 0, 1, 1, 16, 16)

    mouse_delta.x = love.mouse.getX()
    mouse_delta.y = love.mouse.getY()
end
