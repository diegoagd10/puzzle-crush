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
    -- implementation
end

function GameObject:update(delta)
    -- implementation
end

function GameObject:draw()
    -- implementation
end

return GameObject