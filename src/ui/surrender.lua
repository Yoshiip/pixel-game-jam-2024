require "src.ui.ui_element"
require "collision"
vector = require "utils.vector"

Surrender = {}
Surrender.__index = Surrender
setmetatable(Surrender, { __index = UIElement })

function Surrender:new(id, pos, origin, size)
    print(tostring(origin))
    local self = setmetatable(UIElement:new(id, pos, origin, size), Surrender)
    print(tostring(self.origin))
    return self
end



function Surrender:draw()
    local surrender_quad = love.graphics.newQuad(128, 32, 64, 16, UIImage:getDimensions())

    print(self.pos)
    love.graphics.draw(UIImage, surrender_quad, self.pos.x, self.pos.y, 0, 1, 1, 32, 8)

    if self.hovered then
        self:drawTooltip()
    end
end

function Surrender:update()
    UIElement.update(self)
end
