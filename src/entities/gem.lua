local GameObject = require('src.entities.game_object')
local MouseInteractable = require('src.entities.mouse_interactable')

local Gem = {}
Gem.__index = Gem

-- Set up multiple inheritance
local parentMetatable = {__index = GameObject}
setmetatable(Gem, parentMetatable)
setmetatable(parentMetatable, {__index = MouseInteractable})

-- Constants
local MOVEMENT_SPEED = 100  -- pixels per second

-- Color mapping
local COLORS = {
    red = {1, 0, 0, 1},
    blue = {0, 0, 1, 1},
    green = {0, 1, 0, 1},
    yellow = {1, 1, 0, 1},
    purple = {1, 0, 1, 1},
    orange = {1, 0.5, 0, 1},
    default = {0.5, 0.5, 0.5, 1}  -- gray for unset color
}

function Gem.new()
    local self = GameObject.new()  -- Create a new GameObject instance
    setmetatable(self, Gem)        -- Set the metatable to Gem
    self.color = nil
    self.type = nil
    self._state = "idle"  -- Using underscore to indicate private property
    self._mouseX = 0     -- Store current mouse X position
    self._mouseY = 0     -- Store current mouse Y position
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

function Gem:isMouseOver(x, y)
    return x >= self.x and 
           x <= self.x + self.width and 
           y >= self.y and 
           y <= self.y + self.height
end

function Gem:onMousePressed(x, y)
    if self:isMouseOver(x, y) then
        self._state = "selected"
        self._mouseX = x
        self._mouseY = y
    end
end

function Gem:onMouseMoved(x, y)
    self._mouseX = x
    self._mouseY = y
end

function Gem:onMouseReleased(x, y)
    if self._state == "selected" then
        self._state = "idle"
        self._mouseX = 0
        self._mouseY = 0
    end
end

function Gem:update(delta)
    if self._state == "selected" then
        -- Calculate target position (centered on mouse)
        local targetX = self._mouseX - (self.width / 2)
        
        -- Calculate distance to move this frame
        local distance = MOVEMENT_SPEED * delta
        
        -- Move towards target position
        if self.x < targetX then
            self.x = math.min(self.x + distance, targetX)
        elseif self.x > targetX then
            self.x = math.max(self.x - distance, targetX)
        end
    end
end

function Gem:draw(graphics)
    -- Set color based on gem's color property
    local color = COLORS[self.color] or COLORS.default
    graphics:setColor(table.unpack(color))
    
    -- Draw the gem as a filled rectangle
    graphics:rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Reset color to white
    graphics:setColor(1, 1, 1, 1)
end

return Gem