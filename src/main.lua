Atlas = love.graphics.newImage("resources/textures/atlas.png")
vector = require "utils.vector"

GamePos = vector(40, 60)
GameResolution = vector(240, 160)
Resolution = vector(320, 440)

require "scene"
require "scenes.intro"
require "scenes.menu"
require "scenes.game"
require "scenes.shop"
require "scenes.map"

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
    shoot = { "mouse:0", "space" },
    cancel = { "escape", "backspace" },
}

Screens = {
    intro = 1,
    menu = 2,
    game = 3,
    shop = 4,
    map = 5,
}


MousePos = vector(0, 0)
GameMousePos = vector(0, 0)



Fishes = {}
Projectiles = {}
Collisions = {}
Droplets = {}
UIElements = {}

GameData = {
    life = 1,
    level = 1,
    money = 50,
    tsunami_distance = 0,
    player_distance = 0,
}

Scenes = {
    IntroScene:new(),
    MenuScene:new(),
    GameScene:new(),
    ShopScene:new(),
    MapScene:new()
}

UI = UserInterface:new()

CurrentScreen = 1

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


    local x, y = love.window.getPosition()
    last_window_pos = vector(x, y)

    ChangeScene(Screens.shop)
end

local function getScene()
    return Scenes[CurrentScreen]
end

local tileTexture = love.graphics.newImage("resources/textures/tile.png")
tileTexture:setWrap("repeat", "repeat")

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


    local quad = love.graphics.newQuad(0, 0, Resolution.x * Zoom, Resolution.y * Zoom, 32, 32)
    love.graphics.draw(tileTexture, quad, 1, 1)

    love.graphics.draw(GameCanvas, GamePos.x * Zoom, GamePos.y * Zoom, 0, Zoom, Zoom)
    love.graphics.draw(MainCanvas, 0, 0, 0, Zoom, Zoom)
    love.graphics.setColor(0.2, 0.3, 0.9, 0.3)
    love.graphics.draw(DropletsCanvas, 0, 0, 0, Zoom, Zoom)
    love.graphics.setColor(1, 1, 1, 1)
end

function SpawnDroplet()
    local pos = vector(math.random(32, Resolution.x - 32), math.random(32, 240))
    table.insert(Droplets, Droplet:new(pos))
end

function ChangeScene(scene_id)
    CurrentScreen = scene_id
    getScene():start()
end

function PlayerExited()
    ChangeScene(Screens.shop)
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
    GameMousePos.x = (MousePos.x - (GamePos.x * Zoom)) / Zoom
    GameMousePos.y = (MousePos.y - (GamePos.y * Zoom)) / Zoom
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
    if key == "o" then
        Zoom = math.max(Zoom - 1, 1)
        love.window.setMode(Resolution.x * Zoom, Resolution.y * Zoom)
    end
    if key == "p" then
        Zoom = math.max(Zoom + 1, 8)
        love.window.setMode(Resolution.x * Zoom, Resolution.y * Zoom)
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
        if string.sub(hotkey, 1, 5) == "mouse" then
            if love.mouse.isDown(tonumber(string.sub(hotkey, 7, 7))) then
                return true
            end
        elseif love.keyboard.isDown(hotkey) then
            return true
        end
    end
    return false
end
