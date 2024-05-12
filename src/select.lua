vector = require "utils.vector"
require "projectile"
require "collision"

Select = {}
Select.__index = Select

function Select:new(id, options)
    local self = setmetatable({}, Select)
    self.__index = self
    self.id = id
    self.pos = vector(8, 8)
    self.selected = 0
    self.spacing = 20
    self.options = options
    return self
end

function Select:draw()
    for i, option in ipairs(self.options) do
        local base_y = self.pos.y + ((i - 1) * self.spacing)
        if i == self.selected then
            love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
            love.graphics.rectangle("fill", self.pos.x, base_y, GameResolution.x - 32, self.spacing, 10, 10)
            love.graphics.setColor(0.0, 0.0, 0.0, 1.0)
        else
            love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        end
        love.graphics.print(option.text, self.pos.x + 8, base_y)
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
    end
end

function Select:update()
    if self.selected <= 0 then
        self.selected = #self.options
    elseif self.selected > #self.options then
        self.selected = 1
    end
end
