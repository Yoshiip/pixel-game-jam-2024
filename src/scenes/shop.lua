ShopScene = {}
ShopScene.__index = ShopScene
setmetatable(ShopScene, { __index = Scene })

local shop_select = Select:new("shop", {
    {
        id = "continue",
        text = "Continue"
    },
    {
        id = "shop",
        text = "Shop"
    },
})

local items_select = Select:new("shop_items", {
    {
        id = "strength",
        text = "Strength",
    },
    {
        id = "back",
        text = "Back",
    }
})

local current_select = shop_select

local buying = "none"
local sell_visible = false


function ShopScene:new()
    local self = setmetatable(Scene:new(), ShopScene)
    return self
end

function ShopScene:update()
    current_select:update()

    sell_visible = false
    for i, element in ipairs(UIElements) do
        if element.pos.y < GameResolution.y + 64 then
            if element.grabbed then
                sell_visible = true
            else
                element:destroy()
            end
        end
    end
end

function ShopScene:draw()
    love.graphics.setCanvas(GameCanvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.setBlendMode("alpha")

    if buying ~= "none" then
        love.graphics.print("Click where you want to place it", 20, 110)
    elseif sell_visible then
        love.graphics.print("Release to sell", 20, 110)
    end
    love.graphics.print("Money: " .. GameData.money .. " gears", 20, 90)

    current_select:draw()
end

local function selectMenuOptionSelected(option)
    if option.id == "continue" then
        CurrentScreen = Screens.game
    elseif option.id == "shop" then
        current_select = items_select
    elseif current_select.id == "shop_items" then
        if option.id == "back" then
            current_select = shop_select
        else
            buying = option.id
        end
    end
end

function ShopScene:mousepressed(x, y, button)
    if buying ~= "none" then
        local mouse = vector(love.mouse.getX(), love.mouse.getY())
        mouse = mouse / Zoom
        UI:addElement(buying, mouse)
        buying = "none"
    end
end

function ShopScene:keypressed(key)
    if IsKeyPressed("move_up") then
        current_select.selected = current_select.selected - 1
    elseif IsKeyPressed("move_down") then
        current_select.selected = current_select.selected + 1
    end
    if key == "space" then
        selectMenuOptionSelected(current_select.options[current_select.selected])
    end
end
