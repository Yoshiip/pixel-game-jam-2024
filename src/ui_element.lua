vector = require "utils.vector"

UIElement = {}
UIElement.__index = UIElement

function UIElement:new(pos, origin, size)
    local self = setmetatable({}, UIElement)
    self.pos = pos
    self.trauma = 0
    self.disabled = false
    self.origin = origin
    self.size = size
    return self
end

function UIElement:getPosWithTrauma()
    local random_vector = vector(love.math.random(-1.0, 1.0), love.math.random(-1.0, 1.0))
    return math.floor(self.pos.x + (random_vector.x * self.trauma) + 0.5),
        math.floor(self.pos.y + (random_vector.y * self.trauma) + 0.5)
end

function UIElement:draw()
    local x, y = self:getPosWithTrauma()
    love.graphics.draw(
        UIImage,
        love.graphics.newQuad(self.origin.x, self.origin.y, 32, 32, UIImage:getDimensions()),
        x, y, 0, 1, 1, 16, 16
    )
end

function UIElement:update()
    self.trauma = self.trauma * 0.95
end
