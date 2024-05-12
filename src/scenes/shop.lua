ShopScene = {}
ShopScene.__index = ShopScene
setmetatable(ShopScene, { __index = Scene })

local shop_select = Select:new("shop", {
    {
        id = "continue",
        text = "Continue"
    },
    {
        id = "repair",
        text = "Repair"
    },
    {
        id = "shop",
        text = "Shop"
    },
})


local cursorDefault = love.mouse.getSystemCursor("arrow")
local cursorGrab = love.mouse.getSystemCursor("sizeall")


function ShopScene:new()
    local self = setmetatable(Scene:new(), ShopScene)
    return self
end

function ShopScene:update()
    shop_select:update()
end

function ShopScene:draw()
    love.graphics.setCanvas(GameCanvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.setBlendMode("alpha")


    shop_select:draw()
end

function ShopScene:mousepressed(x, y, button)
    if button == 1 then
        for i, button in ipairs(UIElements) do
            if button.hovered then
                button.grabbed = true
                love.mouse.setCursor(cursorGrab)
                button.grab_position = MousePos - button.pos
                return
            end
        end
    end
end

function ShopScene:mousereleased(x, y, button)
    if button == 1 then
        for i, button in ipairs(UIElements) do
            if button.hovered then
                button.grabbed = true
                love.mouse.setCursor(cursorGrab)
                button.grab_position = MousePos - button.pos
                return
            end
        end
    end
end

local function selectMenuOptionSelected(option)
    if option.id == "continue" then
        CurrentScreen = Screens.game
    end
end

function ShopScene:keypressed(key)
    if key == "z" then
        shop_select.selected = shop_select.selected - 1
    elseif key == "s" then
        shop_select.selected = shop_select.selected + 1
    end
    if key == "space" then
        selectMenuOptionSelected(shop_select.options[shop_select.selected])
    end
end
