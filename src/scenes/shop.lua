ShopScene = {}
ShopScene.__index = ShopScene
setmetatable(ShopScene, { __index = Scene })

local tutorial_select = Select:new("tutorial", {
    {
        type = "text",
        texts = {
            "Welcome to the shop!",
            "Here you can buy items to help",
            "you in your journey.",
            "You can also repair items or forge new items.",
            "Click on the item you want to buy, ",
            "and place it on your console.",
            "You can also throw away items by",
            "dragging them to the top of the screen.",
            "The items you throw into the water may",
            "come in handy in the next life.",
        }
    },
    {
        id = "ok",
        text = "Ok",
    },
})

local shop_select = Select:new("shop", {
    {
        id = "continue",
        text = "Continue",
    },
    {
        id = "repair",
        text = "Repair",
    },
    {
        id = "forge",
        text = "Forge",
    },
    {
        id = "shop",
        text = "Shop"
    },
})

local items_select = Select:new("shop_items", {
})

local current_select

Buying = "none"
Forging = false
local sell_visible = false

local function buildShop()
    local items = {
        "strength",
        "racing_shoes",
        "perry_buoy",
    }

    for i, item in ipairs(items) do
        items_select:addItem({
            id = item,
            text = ElementsData[item].name,
            hint = "Price: " .. ElementsData[item].price
        })
    end

    items_select:addItem({
        id = "back",
        text = "Back",
        hint = "Back to main menu"
    })
end

function ShopScene:new()
    local self = setmetatable(Scene:new(), ShopScene)
    return self
end

function ShopScene:start()
    current_select = tutorial_select
    buildShop()
end

function ShopScene:update()
    current_select:update()

    if IsKeyPressed("cancel") then
        Buying = "none"
    end

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
    current_select:draw()

    if Forging then
        love.graphics.print("Grab item onto each other to merge them", 20, 110)
    elseif Buying ~= "none" then
        love.graphics.print("Click where you want to place it", 20, 110)
    elseif sell_visible then
        love.graphics.print("Release to sell", 20, 110)
    end
    love.graphics.print("Money: " .. GameData.money .. " gears", 20, 90)
end

local function selectMenuOptionSelected(option)
    if option.id == nil then
        return
    end
    if option.id == "ok" then
        current_select = shop_select
    elseif option.id == "repair" then
        current_select = shop_select
    elseif option.id == "forge" then
        Forging = true
    elseif option.id == "continue" then
        ChangeScene(Screens.map)
    elseif option.id == "shop" then
        current_select = items_select
    elseif current_select.id == "shop_items" then
        if option.id == "back" then
            current_select = shop_select
        else
            Buying = option.id
        end
    end
end

function ShopScene:mousepressed(x, y, button)
    if Buying ~= "none" then
        local mouse = vector(love.mouse.getX(), love.mouse.getY())
        mouse = mouse / Zoom
        UI:addElement(Buying, mouse)
        Buying = "none"
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
