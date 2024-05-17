vector = require "utils.vector"
require "projectile"
require "collision"

Select = {}
Select.__index = Select

function Select:new(id, options, pos, size)
    local self = setmetatable({}, Select)
    self.__index = self
    self.id = id
    self.pos = pos or vector(0, 0)
    self.size = size or vector(GameResolution.x - self.pos.x, GameResolution.y - self.pos.y)
    self.selected = 0
    self.spacing = 20
    self.options = options
    return self
end

function Select:draw()
    love.graphics.setColor(0.1, 0.3, 0.3, 1.0)
    love.graphics.rectangle("fill", self.pos.x, self.pos.y, self.size.x, self.size.y, 10, 10)
    love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
    local offset = self.pos.y
    for i, option in ipairs(self.options) do
        if self.options[i].type == "text" then
            for i, line in ipairs(self.options[i].texts) do
                love.graphics.print(line, self.pos.x + 8, offset)
                offset = offset + 10
            end
        else
            if i == self.selected then
                love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
                love.graphics.rectangle("fill", self.pos.x, offset, self.size.x, self.spacing, 10, 10)
                love.graphics.setColor(0.0, 0.0, 0.0, 1.0)
            else
                love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
            end
            love.graphics.print(option.text, self.pos.x + 8, offset)
            love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        end
        offset = offset + self.spacing
    end

    -- draw hint
    if self.options[self.selected] and self.options[self.selected].hint then
        love.graphics.setColor(0.3, 0.3, 0.2, 1.0)
        love.graphics.rectangle("fill", self.pos.x, self.pos.y + self.size.y - 32, self.size.x, 32, 10, 10)
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        love.graphics.print(self.options[self.selected].hint, self.pos.x, self.pos.y + self.size.y - 16)
    end
end

function Select:addItem(item)
    table.insert(self.options, item)
end

function Select:update()
    if self.selected <= 0 then
        self.selected = #self.options
    elseif self.selected > #self.options then
        self.selected = 1
    end
end
