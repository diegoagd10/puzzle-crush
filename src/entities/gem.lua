local GameObject = require('src.entities.GameObject')

local Gem = {}
Gem.__index = Gem
setmetatable(Gem, {__index = GameObject})

function Gem.new()
    local self = GameObject.new()  -- Create a new GameObject instance
    setmetatable(self, Gem)        -- Set the metatable to Gem
    self.color = nil
    self.type = nil
    self._state = "idle"  -- Using underscore to indicate private property
    return self
end

function Gem:setPosition(x, y)
    self.x = x
    self.y = y
end

function Gem:getPosition()
    return self.x, self.y
end

function Gem:setDimensions(width, height)
    self.width = width
    self.height = height
end

function Gem:setColor(color)
    self.color = color
end

function Gem:getColor()
    return self.color
end

function Gem:setType(type)
    self.type = type
end

function Gem:getType()
    return self.type
end

function Gem:getState()
    return self._state
end

return Gem