Scene = {}
Scene.__index = Scene


function Scene:new(pos)
    local self = setmetatable({}, Scene)
    return self
end

function Scene:start()
end

function Scene:draw()
end

function Scene:update()
end

function Scene:keypressed(key)
end

function Scene:mousepressed(x, y, key)
end

function Scene:mousereleased(x, y, key)

end
