vector = require "utils.vector"

UIElement = {}
UIElement.__index = UIElement

function UIElement:new(id, pos, origin, size)
    local self = setmetatable({}, UIElement)
    self.id = id
    self.pos = pos
    self.trauma = 0.0
    self.hovered = false
    self.disabled = false
    self.origin = origin
    self.size = size
    self.collision = Collision:new(self, "button", pos, size)
    table.insert(Collisions, self.collision)
    return self
end

function UIElement:destroy()
    table.remove(Collisions, indexOf(Collisions, self.collision))
    table.remove(UIElements, indexOf(UIElements, self))
end

function UIElement:damage(amt)

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

    if self.hovered then
        self:drawTooltip()
    end
end

function UIElement:drawTooltip()
    if self.hovered then
        local data = ElementsData[self.id]
        local base_offset = self.pos + vector(8, 8)
        love.graphics.setColor(0.4, 0.4, 0.4, 0.3)
        love.graphics.rectangle("fill", base_offset.x, base_offset.y, 80, 40)
        love.graphics.setColor(0.9, 0.9, 0.9, 0.8)
        love.graphics.setLineWidth(0.5)
        love.graphics.rectangle("line", base_offset.x, base_offset.y, 80, 40)
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        local i = 0
        if data.name ~= nil then
            love.graphics.print(data.name, base_offset.x + 4, base_offset.y + (16 * i))
            i = i + 1
        end
        if data.max_health ~= nil then
            love.graphics.print(self.health .. "/" .. data.max_health, base_offset.x + 4, base_offset.y + (16 * i))
            i = i + 1
        end
    end
end

function UIElement:update()
    self.trauma = self.trauma * 0.95
    if self.collision:checkPoint(MousePos) then
        self.hovered = true
    else
        self.hovered = false
    end
end
