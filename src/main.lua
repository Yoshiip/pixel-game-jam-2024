Atlas = love.graphics.newImage("resources/textures/atlas.png")
vector = require "utils.vector"

GameResolution = vector(240, 160)
Resolution = vector(320, 400)

require "scene"
require "scenes.intro"
require "scenes.menu"
require "scenes.game"
require "scenes.shop"

require "duck"
require "fish"
require "ui"
require "collision"
require "droplet"
require "select"


Bindings = {
    move_up = { "z", "w", "up" },
    move_left = { "q", "a", "left" },
    move_down = { "s", "s", "down" },
    move_right = { "d", "d", "right" },
}

Screens = {
    intro = 1,
    menu = 2,
    game = 3,
    shop = 4
}


MousePos = vector(0, 0)
GameMousePos = vector(0, 0)



Fishes = {}
Projectiles = {}
Collisions = {}
Droplets = {}
UIElements = {}

GameData = {
    money = 50
}

Scenes = {
    IntroScene:new(),
    MenuScene:new(),
    GameScene:new(),
    ShopScene:new(),
}

UI = UserInterface:new()

CurrentScreen = Screens.shop

Zoom = 2



GameCanvas = love.graphics.newCanvas()
MainCanvas = love.graphics.newCanvas()

DropletsCanvas = love.graphics.newCanvas()




if arg[2] == "debug" then
    require("lldebugger").start()
end



local last_window_pos

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest", 0)
    love.window.setMode(Resolution.x * Zoom, Resolution.y * Zoom)
    MainCanvas = love.graphics.newCanvas(Resolution.x, Resolution.y)
    GameCanvas = love.graphics.newCanvas(GameResolution.x, GameResolution.y)
    DropletsCanvas = love.graphics.newCanvas(Resolution.x, Resolution.y)

    love.window.setTitle("chips")

    local font = love.graphics.newFont("resources/fonts/monogram-extended.ttf", 16)
    love.graphics.setFont(font)


    Player = Duck:new()

    for i = 1, 5 do
        local pos = vector(math.random(0, 240), math.random(0, 160))
        table.insert(Fishes, Fish:new(love.math.random(1, 4), pos))
    end


    local x, y = love.window.getPosition()
    last_window_pos = vector(x, y)
end

local function getScene()
    return Scenes[CurrentScreen]
end

function love.draw()
    love.graphics.setCanvas(MainCanvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setBlendMode("alpha")
    UI:draw()



    getScene():draw()

    love.graphics.setCanvas(MainCanvas)
    if DebugCollision then
        for i, collision in ipairs(Collisions) do
            collision:draw()
        end
    end

    love.graphics.setCanvas()

    love.graphics.setBlendMode("alpha", "premultiplied")

    love.graphics.draw(GameCanvas, 40 * Zoom, 40 * Zoom, 0, Zoom, Zoom)
    love.graphics.draw(MainCanvas, 0, 0, 0, Zoom, Zoom)
    love.graphics.setColor(0.2, 0.3, 0.9, 0.3)
    love.graphics.draw(DropletsCanvas, 0, 0, 0, Zoom, Zoom)
    love.graphics.setColor(1, 1, 1, 1)
end

function SpawnDroplet()
    local pos = vector(math.random(32, Resolution.x - 32), math.random(32, 240))
    table.insert(Droplets, Droplet:new(pos))
end

function PlayerExited()
    CurrentScreen = Screens.shop
end

local function handleWindowShake()
    local x, y = love.window.getPosition()
    if vector(x, y) - last_window_pos ~= vector(0, 0) then
        for i, droplet in ipairs(Droplets) do
            droplet.lifetime = droplet.lifetime - 1
        end
    end
    last_window_pos = vector(x, y)
end


function love.update()
    MousePos.x = love.mouse.getX()
    MousePos.y = love.mouse.getY()
    GameMousePos.x = (MousePos.x - (40 * Zoom)) / Zoom
    GameMousePos.y = (MousePos.y - (40 * Zoom)) / Zoom
    MousePos = MousePos / Zoom


    UI:update()
    getScene():update()

    handleWindowShake()
end

function love.mousereleased(x, y, button)
    getScene():mousereleased(x, y, button)
    UI:mousereleased(x, y, button)
end

function love.mousepressed(x, y, button)
    getScene():mousepressed(x, y, button)
    UI:mousepressed(x, y, button)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    if key == "o" then
        Zoom = Zoom - 1
        love.window.setMode(320 * Zoom, 400 * Zoom)
    end
    if key == "p" then
        Zoom = Zoom + 1
        love.window.setMode(320 * Zoom, 400 * Zoom)
    end
    getScene():keypressed(key)
end

local love_errorhandler = love.errorhandler

function love.errorhandler(msg)
    if lldebugger then
        error(msg, 2)
    else
        return love_errorhandler(msg)
    end
end

function indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

function IsKeyPressed(binding_id)
    for i, hotkey in ipairs(Bindings[binding_id]) do
        if love.keyboard.isDown(hotkey) then
            return true
        end
    end
    return false
end
