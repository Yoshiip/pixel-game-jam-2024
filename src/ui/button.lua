require "src.ui.ui_element"
require "collision"
vector = require "utils.vector"

Button = {}
Button.__index = Button
setmetatable(Button, { __index = UIElement })

function Button:new(id, pos, origin, size)
    local self = setmetatable(UIElement:new(id, pos, origin, size), Button)

    self.max_health = 5
    self.health = self.max_health
    self.disabled = false
    self.grab_valid = false
    self.grab_base_position = vector(0, 0)
    return self
end

function Button:getPosWithTrauma()
    local random_vector = vector(love.math.random(-1.0, 1.0), love.math.random(-1.0, 1.0))
    return math.floor(self.pos.x + (random_vector.x * self.trauma) + 0.5),
        math.floor(self.pos.y + (random_vector.y * self.trauma) + 0.5)
end

function Button:draw()
    local pressed = false
    if not self.disabled and IsKeyPressed(self.id) then
        pressed = true
    end

    local quad_offset = vector(self.origin.x, self.origin.y)
    if self.disabled then
        quad_offset.x = quad_offset.x + 64
    elseif pressed then
        quad_offset.x = quad_offset.x + 32
    elseif self.hovered then
        quad_offset.x = quad_offset.x + 96
    end

    local quad = love.graphics.newQuad(quad_offset.x, quad_offset.y, 32, 32, UIImage:getDimensions())
    local x, y = self:getPosWithTrauma()
    love.graphics.draw(UIImage, quad, x, y, 0, 1, 1, 16, 16)


    if self.hovered then
        self:drawTooltip()
    end
end

function Button:damage(amt)
    self.health = math.max(self.health - amt, 0)
    if self.health <= 0 then
        self.disabled = true
    end
    self.trauma = 10
end

function Button:update()
    UIElement.update(self)
    UIElement.handleGrab(self)
end
