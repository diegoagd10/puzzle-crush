local GameObject = require('src.entities.game_object')
local MouseInteractable = require('src.entities.mouse_interactable')

local Gem = {}
Gem.__index = Gem

-- Set up multiple inheritance
local parentMetatable = {__index = GameObject}
setmetatable(Gem, parentMetatable)
setmetatable(parentMetatable, {__index = MouseInteractable})

-- Constants
local MOVEMENT_SPEED = 550  -- pixels per second
local PADDING = 5  -- padding between gems

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
    self._originalX = 0  -- Store original X position
    self._originalY = 0  -- Store original Y position
    self._offsetX = 0    -- Store offset between mouse and gem center X
    self._offsetY = 0    -- Store offset between mouse and gem center Y
    self._isValidRelease = false  -- Flag to track if release is over valid position
    return self
end

function Gem:setPosition(x, y)
    self.x = x
    self.y = y
end

function Gem:getPosition()
    return self.x, self.y
end

function Gem:setGridPosition(col, row)
    local x = col * (self.width + PADDING)
    local y = row * (self.height + PADDING)
    self:setPosition(x, y)
end

function Gem:getGridPosition()
    return math.floor(self.x / (self.width + PADDING)), 
           math.floor(self.y / (self.height + PADDING))
end

function Gem:getVisualPosition()
    return self.x + PADDING, self.y + PADDING
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
    local visualX, visualY = self:getVisualPosition()
    return x >= visualX and 
           x <= visualX + self.width and 
           y >= visualY and 
           y <= visualY + self.height
end

function Gem:onMousePressed(x, y)
    if self:isMouseOver(x, y) then
        self._state = "selected"
        
        -- Calculate the center of the gem (accounting for padding)
        local centerX = self.x + PADDING + (self.width / 2)
        local centerY = self.y + PADDING + (self.height / 2)
        
        -- Store initial offset from mouse to gem center
        self._offsetX = x - centerX
        self._offsetY = y - centerY
        
        -- Store current mouse position
        self._mouseX = x
        self._mouseY = y
        
        -- Store original position for bounds checking
        self._originalX = self.x
        self._originalY = self.y
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
        self.x = self._originalX
        self.y = self._originalY
    end
end

function Gem:update(delta)
    if self._state == "selected" then
        self:updateDraggedPosition(delta)
    end
end

function Gem:updateDraggedPosition(delta)
    -- Calculate where the center of the gem should be (removing the initial offset)
    local targetCenterX = self._mouseX - self._offsetX
    local targetCenterY = self._mouseY - self._offsetY
    
    -- Convert from center coordinates to top-left coordinates
    local targetX = targetCenterX - PADDING - (self.width / 2)
    local targetY = targetCenterY - PADDING - (self.height / 2)
    
    -- Calculate the maximum allowed movement (1x width/height)
    local maxMovementX = self.width
    local maxMovementY = self.height
    
    -- Clamp the target position to the maximum allowed movement
    local maxX = self._originalX + maxMovementX
    local minX = self._originalX - maxMovementX
    targetX = math.max(minX, math.min(maxX, targetX))
    
    local maxY = self._originalY + maxMovementY
    local minY = self._originalY - maxMovementY
    targetY = math.max(minY, math.min(maxY, targetY))
    
    -- Calculate the vector from origin to target position
    local vectorX = targetX - self._originalX
    local vectorY = targetY - self._originalY
    
    -- Calculate the angle of movement using atan2 (returns angle in range -π to π)
    local angle = math.atan2(vectorY, vectorX)
    
    -- Convert to degrees for easier reasoning (0-360 degrees)
    local degrees = (angle * 180 / math.pi)
    if degrees < 0 then degrees = degrees + 360 end
    
    -- Calculate distance to move this frame
    local distance = MOVEMENT_SPEED * delta
    
    -- Determine movement direction based on angle sectors:
    -- Horizontal sectors: -45° to 45° (or 315° to 45°) and 135° to 225°
    -- Vertical sectors: 45° to 135° and 225° to 315°
    --
    --            90° (up)
    --              ^
    --              |
    --  180° <--   +   --> 0°/360°
    --              |
    --              v
    --           270° (down)
    if (degrees >= 315 or degrees < 45) or (degrees >= 135 and degrees < 225) then
        -- Horizontal movement (right/left directions)
        if self.x < targetX then
            self.x = math.min(self.x + distance, targetX)
        elseif self.x > targetX then
            self.x = math.max(self.x - distance, targetX)
        end
        -- Keep vertical position at original
        self.y = self._originalY
    else
        -- Vertical movement (up/down directions)
        if self.y < targetY then
            self.y = math.min(self.y + distance, targetY)
        elseif self.y > targetY then
            self.y = math.max(self.y - distance, targetY)
        end
        -- Keep horizontal position at original
        self.x = self._originalX
    end
end

function Gem:draw(graphics)
    -- Set color based on gem's color property
    local color = COLORS[self.color] or COLORS.default
    local r, g, b, a = color[1], color[2], color[3], color[4]
    graphics:setColor(r, g, b, a)
    
    -- Draw the gem as a circle using visual position
    local radius = math.min(self.width, self.height) / 2
    local visualX, visualY = self:getVisualPosition()
    local centerX = visualX + radius
    local centerY = visualY + radius
    graphics:circle("fill", centerX, centerY, radius)
    
    -- Reset color to white
    graphics:setColor(1, 1, 1, 1)
end

return Gem