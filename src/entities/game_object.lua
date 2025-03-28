local GameObject = {}
GameObject.__index = GameObject

function GameObject.new()
    local self = setmetatable({}, GameObject)
    self.x = 0
    self.y = 0
    self.width = 0
    self.height = 0
    return self
end

function GameObject:load()
end

function GameObject:update(delta)
end

function GameObject:draw()
end

return GameObject