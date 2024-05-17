require "select"


local sign_select = Select:new("sign", {
    {
        id = "go_up",
        text = "Aller en haut",
    },
    {
        id = "go_down",
        text = "Aller en bas",
    },
},
vector(0, 80)
)

local current_menu = sign_select

MapScene = {}
MapScene.__index = MapScene
setmetatable(MapScene, { __index = Scene })

function MapScene:new()
    local self = setmetatable(Scene:new(), MapScene)
    return self
end

function MapScene:start()
    current_menu = sign_select
end

function MapScene:draw()
    love.graphics.setCanvas(GameCanvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.setBlendMode("alpha")

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Tsunami", 8, 8)

    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.print("1000m", 8, 24)

    current_menu:draw()
end

function MapScene:update()
    current_menu:update()
end

local function applyEffect()
    ChangeScene(Screens.game)
end

local function selectMenuOptionSelected(option)
    if option.id == "go_up" then
        applyEffect()
    elseif option.id == "go_down" then
        applyEffect()
    end
end

function MapScene:keypressed(key)
    if key == "z" then
        current_menu.selected = current_menu.selected - 1
    elseif key == "s" then
        current_menu.selected = current_menu.selected + 1
    end
    if key == "space" then
        selectMenuOptionSelected(current_menu.options[current_menu.selected])
    end
end
