require "src.ui.ui_element"
require "ui.button"
require "ui.emblem"
require "ui.joystick"
require "ui.surrender"

vector = require "utils.vector"




local frame = love.graphics.newImage("resources/textures/frame_2.png")
UIImage = love.graphics.newImage("resources/textures/ui.png")

UserInterface = {}
UserInterface.__index = UserInterface





-- elements at rarity -1 are not availables to buy
ElementsData = {
    move_left = {
        type = "button",
        name = "D-PAD Left",
        max_health = 5,
        rarity = -1,
        origin = vector(0, 0),
        size = vector(30, 16),
    },
    move_up = {
        type = "button",
        name = "D-PAD Up",
        max_health = 5,
        rarity = -1,
        origin = vector(0, 32),
        size = vector(16, 30),
    },
    move_right = {
        type = "button",
        name = "D-PAD Right",
        max_health = 5,
        rarity = -1,
        origin = vector(0, 64),
        size = vector(30, 16),
    },
    move_down = {
        type = "button",
        name = "D-PAD Down",
        max_health = 5,
        rarity = -1,
        origin = vector(0, 96),
        size = vector(16, 30),
    },
    joystick = {
        type = "joystick",
        name = "Aim Joystick",
        max_health = 5,
        rarity = -1,
        size = vector(32, 32)
    },
    surrender = {
        type = "surrender",
        name = "Surrender",
        origin = vector(128, 32),
        size = vector(64, 16),
    },
    strength = {
        type = "emblem",
        name = "Damage bonus",
        origin = vector(0, 224),
        size = vector(24, 24),
        rarity = 3,
        price = 5,
        max_levels = 3,
    },
    racing_shoes = {
        type = "emblem",
        name = "Speed bonus",
        description = "Increase your speed by 20%",
        origin = vector(96, 256),
        size = vector(24, 24),
        rarity = 3,
        price = 5,
        max_levels = 3,
    },
    perry_buoy = {
        type = "emblem",
        name = "Perry Buoy",
        description = "Increase speed in water",
        origin = vector(96, 288),
        size = vector(24, 24),
        rarity = 3,
        price = 5,
        max_levels = 3,
    },
}


function UserInterface:addElement(id, pos)
    local data = ElementsData[id]

    if data.type == "button" then
        table.insert(UIElements, Button:new(
            id,
            pos,
            data.origin,
            data.size
        ))
    elseif data.type == "joystick" then
        table.insert(UIElements, Joystick:new(
            id,
            pos,
            data.size
        ))
    elseif data.type == "emblem" then
        table.insert(UIElements, Emblem:new(
            id,
            pos,
            data.origin,
            data.size
        ))
    elseif data.type == "surrender" then
        print(data.origin)
        table.insert(UIElements, Surrender:new(
            id,
            pos,
            data.origin,
            data.size
        ))
    elseif data.type == "element" then
        table.insert(UIElements, UIElement:new(
            id,
            pos,
            data.origin,
            data.size
        ))
    end
end

function UserInterface:new()
    local self = setmetatable({}, UserInterface)



    -- dpad
    local arrowSize = 48
    local half = arrowSize / 2
    local dPadPos = vector(64, 300)
    self:addElement("move_left", vector(dPadPos.x - half, dPadPos.y))
    self:addElement("move_up", vector(dPadPos.x, dPadPos.y - half))
    self:addElement("move_down", vector(dPadPos.x, dPadPos.y + half))
    self:addElement("move_right", vector(dPadPos.x + half, dPadPos.y))
    self:addElement("surrender", vector(64, 10))

    self:addElement("joystick", vector(Resolution.x - 64, 300))

    return self
end

function UserInterface:CountElementWorking(element_id)
    local count = 0
    for i, element in ipairs(UIElements) do
        if element.id == element_id and element.health ~= nil and element.health > 0 then
            count = count + 1
        end
    end
    return count
end

function UserInterface:getButtonsWorking()
    local buttonsWorking = {}
    for i, element in ipairs(UIElements) do
        if element.health ~= nil and element.health > 0 then
            buttonsWorking[element.id] = true
        end
    end
    return buttonsWorking
end

function UserInterface:draw()
    love.graphics.draw(frame, 0, 0)

    for i, element in ipairs(UIElements) do
        element:draw()
    end
end

local cursorDefault = love.mouse.getSystemCursor("arrow")
local cursorHand = love.mouse.getSystemCursor("hand")
local cursorGrab = love.mouse.getSystemCursor("sizeall")
local cursorNo = love.mouse.getSystemCursor("no")
local cursorCrosshair = love.mouse.getSystemCursor("crosshair")
local cursorMerge = love.mouse.getSystemCursor("sizens")


function UserInterface:update()
    for i, element in ipairs(UIElements) do
        element:update()
    end

    local element_hovered = 0
    local element_grabbed = 0
    for i, element in ipairs(UIElements) do
        if element.grabbed then
            element_grabbed = element_grabbed + 1
        elseif element.hovered then
            element_hovered = element_hovered + 1
        end
    end

    if element_grabbed > 0 then
        love.mouse.setCursor(cursorGrab)
    elseif element_hovered > 0 then
        if CurrentScreen == Screens.shop then
            love.mouse.setCursor(cursorHand)
        else
            love.mouse.setCursor(cursorNo)
        end
    elseif Buying ~= "none" then
        love.mouse.setCursor(cursorCrosshair)
    else
        love.mouse.setCursor(cursorDefault)
    end
end

function UserInterface:mousepressed(x, y, button)
    if button == 1 then
        if CurrentScreen == Screens.shop then
            for i, element in ipairs(UIElements) do
                if element.hovered then
                    element.grabbed = true
                    element.grab_position = MousePos - element.pos
                    return
                end
            end
        else
            for i, element in ipairs(UIElements) do
                if element.hovered then
                    element.trauma = 4
                end
            end
        end
    end
end

function UserInterface:mergeElements(a, b)
    if a.id == b.id then
        a.level = a.level + 1
        b:destroy()
    end
end

function UserInterface:mousereleased(x, y, button)
    if button == 1 then
        for i, element in ipairs(UIElements) do
            if element.grabbed then
                if Forging then
                    print("forging")
                    for i = #Collisions, 1, -1 do
                        local coll = Collisions[i]
                        local colliding = Collision.checkRectangle(element.collision, coll)
                        if (colliding) then
                            UserInterface:mergeElements(element, coll.owner)
                        end
                    end
                end
                element.grabbed = false
            end
        end
    end
end

function math.clamp(low, n, high) return math.min(math.max(n, low), high) end

function math.round(n) return math.floor(n + 0.5) end
