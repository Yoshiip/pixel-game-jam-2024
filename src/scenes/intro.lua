IntroScene = {}
IntroScene.__index = IntroScene
setmetatable(IntroScene, { __index = Scene })

function IntroScene:new()
    local self = setmetatable(Scene:new(), IntroScene)
    return self
end

function IntroScene:update()

end

function IntroScene:draw()

end
