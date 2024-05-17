GameScene = {}
GameScene.__index = GameScene
setmetatable(GameScene, { __index = Scene })

local ground = love.graphics.newImage("resources/textures/ground.png")
local water_zone_texture = love.graphics.newImage("resources/textures/water_zone.png")
local test_water_texture = love.graphics.newImage("resources/textures/terrains/4.png")
ground:setWrap("repeat", "repeat")


local small_shadow_quad = love.graphics.newQuad(0, 64, 32, 32, Atlas:getDimensions())
local medium_shadow_quad = love.graphics.newQuad(32, 64, 32, 32, Atlas:getDimensions())
local water_shader = love.graphics.newShader("resources/shaders/water.glsl")


local water_zones = {}


function GameScene:new()
    local self = setmetatable(Scene:new(), GameScene)
    for i = 1, 50, 1 do
        table.insert(water_zones, {
            x = love.math.random(0, GameResolution.x),
            y = love.math.random(0, GameResolution.y),
        })
    end
    table.sort(water_zones, function(a, b) return a.y > b.y end)
    return self
end

function GameScene:generateWave()
    local points = 50 + GameData.level * 25
    while points > 0 do
        local random_enemy = Enemies[love.math.random(1, 4)]
        if random_enemy.min_level >= GameData.level then
            local pos = vector(love.math.random(0, 240), love.math.random(0, 160))
            table.insert(Fishes, Fish:new(love.math.random(1, 4), pos))
            points = points - random_enemy.max_health
        end
    end
end

function GameScene:start()
    Duck.pos = GameResolution / 2

    self:generateWave()
end

function GameScene:update()
    if #Fishes == 0 then
        Player.zone_cleared = true
    else
        Player.zone_cleared = false
    end

    Player:update()

    for i, fish in ipairs(Fishes) do
        fish:update()
    end

    for i, projectile in ipairs(Projectiles) do
        projectile:update()
    end

    for i, droplet in ipairs(Droplets) do
        droplet:update()
    end
end

function GameScene:draw()
    love.graphics.setCanvas(GameCanvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setBlendMode("alpha")

    love.graphics.draw(ground, love.graphics.newQuad(0, 0, 240, 160, ground:getDimensions()), 0, 0, 0, 1, 1)
    love.graphics.setShader(water_shader)
    love.graphics.draw(test_water_texture, love.graphics.newQuad(0, 0, 240, 160, test_water_texture:getDimensions()), 0,
        0, 0, 1, 1)

    for i, water in ipairs(water_zones) do
        love.graphics.draw(water_zone_texture, water.x, water.y)
    end

    -- draw all shadows
    love.graphics.setColor(1, 1, 1, 0.4)
    if not Player.in_water then
        love.graphics.draw(Atlas, medium_shadow_quad, (Player.pos - vector(16, 0)):unpackInt())
    end
    for i, fish in ipairs(Fishes) do
        love.graphics.draw(Atlas, small_shadow_quad, (fish.pos - vector(16, 0)):unpackInt())
    end


    for i, projectile in ipairs(Projectiles) do
        love.graphics.draw(Atlas, small_shadow_quad, (projectile.pos - vector(16, projectile.height)):unpackInt())
    end
    love.graphics.setColor(1, 1, 1, 1)

    Player:draw()

    love.graphics.setShader()

    for i, fish in ipairs(Fishes) do
        fish:draw()
    end

    for i, projectile in ipairs(Projectiles) do
        projectile:draw()
    end


    if #Fishes == 0 then
        love.graphics.print("Archipelago cleaned", 40, 20)
        love.graphics.print("Get out of here!", 40, 40)
    end



    love.graphics.setCanvas(DropletsCanvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setBlendMode("alpha")

    for i, droplet in ipairs(Droplets) do
        droplet:draw()
    end
end

function GameScene:mousepressed(x, y, button)
    if button == 1 then
        Player:shoot()
    end
end

function GameScene:mousereleased(x, y, button)
    if button == 1 then
    end
end
