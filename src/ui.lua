require "ui_element"
require "button"
vector = require "utils.vector"




local frame = love.graphics.newImage("resources/textures/frame.png")
UIImage = love.graphics.newImage("resources/textures/ui.png")

UI = {}
UI.__index = UI


local dPadPos = vector(64, 300)
local joystick_pos = vector(200, 320)
local joystick_quad = love.graphics.newQuad(32, 224, 32, 32, UIImage:getDimensions())

local arrowSize = 48

local d_pad_left_origin = vector(0, 0)
local d_pad_up_origin = vector(0, 32)
local d_pad_right_origin = vector(0, 64)
local d_pad_down_origin = vector(0, 96)




local inertia = vector(0, 0)
local mouse_delta = vector(0, 0)


function UI:new()
    local self = setmetatable({}, UI)

    -- add ui elements

    local half = arrowSize / 2
    table.insert(UIElements, Button:new(
        "q",
        vector(dPadPos.x - half, dPadPos.y),
        d_pad_left_origin,
        vector(30, 16)
    ))
    table.insert(UIElements, Button:new(
        "z",
        vector(dPadPos.x, dPadPos.y - half),
        d_pad_up_origin,
        vector(16, 30)
    ))
    table.insert(UIElements, Button:new(
        "s",
        vector(dPadPos.x, dPadPos.y + half),
        d_pad_down_origin,
        vector(16, 30)
    ))
    table.insert(UIElements, Button:new(
        "d",
        vector(dPadPos.x + half, dPadPos.y),
        d_pad_right_origin,
        vector(30, 16)
    ))

    table.insert(UIElements, UIElement:new(
        vector(64, 256),
        vector(128, 0),
        vector(32, 32)
    ))
    table.insert(UIElements, UIElement:new(
        vector(Resolution.x - 64, 256),
        vector(128, 0),
        vector(32, 32)
    ))

    return self
end

function UI:draw()
    love.graphics.draw(frame, 0, 0)

    for i, element in ipairs(UIElements) do
        element:draw()
    end

    local max_length = 640
    inertia = inertia - (mouse_delta - vector(love.mouse.getX(), love.mouse.getY()))
    inertia = inertia * 0.8
    inertia = inertia:normalized() * math.sqrt(math.min(inertia:len(), max_length))

    local joystick_base_quad = love.graphics.newQuad(32, 192, 32, 32, UIImage:getDimensions())
    local quad = love.graphics.newQuad(0, 192, 32, 32, UIImage:getDimensions())

    love.graphics.draw(UIImage, joystick_base_quad, joystick_pos.x, joystick_pos.y)
    love.graphics.draw(UIImage, quad, math.floor(joystick_pos.x + inertia.x + 0.5),
        math.floor(joystick_pos.y + inertia.y + 0.5))

    mouse_delta.x = love.mouse.getX()
    mouse_delta.y = love.mouse.getY()
end

function UI:update()
    for i, element in ipairs(UIElements) do
        element:update()
    end
end

function math.clamp(low, n, high) return math.min(math.max(n, low), high) end

function math.round(n) return math.floor(n + 0.5) end
