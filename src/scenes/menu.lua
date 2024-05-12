require "select"


local main_menu_select = Select:new("main_menu", {
    {
        id = "play",
        text = "Play"
    },
    {
        id = "credits",
        text = "Credits"
    },
    {
        text = "Quit Game"
    },
})

local credits_select = Select:new("credits", {
    {
        text = "Chips"
    },
    {
        text = "Made by Aymeri"
    },
    {
        text = "With Love"
    },
    {
        text = "For the Pixel Game Jam 2024"
    },
    {
        id = "back",
        text = "Back"
    }
})


local current_menu = main_menu_select

MenuScene = {}
MenuScene.__index = MenuScene
setmetatable(MenuScene, { __index = Scene })

function MenuScene:new()
    local self = setmetatable(Scene:new(), MenuScene)
    return self
end

function MenuScene:draw()
    love.graphics.setCanvas(GameCanvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.setBlendMode("alpha")

    current_menu:draw()
end

function MenuScene:update()
    current_menu:update()
end

local function selectMenuOptionSelected(option)
    if current_menu.id == "main_menu" then
        if option.id == "play" then
            CurrentScreen = Screens.game
        end
        if option.id == "credits" then
            current_menu = credits_select
        end
    end
    if current_menu.id == "credits" then
        if option.id == "back" then
            current_menu = main_menu_select
        end
    end
end

function MenuScene:keypressed(key)
    if key == "z" then
        current_menu.selected = current_menu.selected - 1
    elseif key == "s" then
        current_menu.selected = current_menu.selected + 1
    end
    if key == "space" then
        selectMenuOptionSelected(current_menu.options[current_menu.selected])
    end
end
