local GameObject = require('src.entities.game_object')
local MouseInteractable = require('src.entities.mouse_interactable')

local Gem = {}
Gem.__index = Gem

-- Set up multiple inheritance
local parentMetatable = { __index = GameObject }
setmetatable(Gem, parentMetatable)
setmetatable(parentMetatable, { __index = MouseInteractable })

-- Constants
local MOVEMENT_SPEED = 550 -- pixels per second
local PADDING = 5          -- padding between gems

-- Color mapping
local COLORS = {
    red = { 1, 0, 0, 1 },
    blue = { 0, 0, 1, 1 },
    green = { 0, 1, 0, 1 },
    yellow = { 1, 1, 0, 1 },
    purple = { 1, 0, 1, 1 },
    orange = { 1, 0.5, 0, 1 },
    default = { 0.5, 0.5, 0.5, 1 } -- gray for unset color
}

function Gem.new()
    local self = GameObject.new() -- Create a new GameObject instance
    setmetatable(self, Gem)       -- Set the metatable to Gem
    self.color = nil
    self.type = nil
    self._state = "idle"         -- Using underscore to indicate private property
    self._mouseX = 0             -- Store current mouse X position
    self._mouseY = 0             -- Store current mouse Y position
    self._originalX = 0          -- Store original X position
    self._originalY = 0          -- Store original Y position
    self._offsetX = 0            -- Store offset between mouse and gem center X
    self._offsetY = 0            -- Store offset between mouse and gem center Y
    self._isValidRelease = false -- Flag to track if release is over valid position
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
        self:storeMouseOffsetFromCenter(x, y)
        self:storeOriginalPosition()
    end
end

function Gem:storeMouseOffsetFromCenter(x, y)
    local centerX = self.x + PADDING + (self.width / 2)
    local centerY = self.y + PADDING + (self.height / 2)

    self._offsetX = x - centerX
    self._offsetY = y - centerY

    self._mouseX = x
    self._mouseY = y
end

function Gem:storeOriginalPosition()
    self._originalX = self.x
    self._originalY = self.y
end

function Gem:onMouseMoved(x, y)
    self._mouseX = x
    self._mouseY = y
end

function Gem:onMouseReleased(x, y)
    if self._state == "selected" then
        self:resetGemState()
        self:resetToOriginalPosition()
    end
end

function Gem:resetGemState()
    self._state = "idle"
    self._mouseX = 0
    self._mouseY = 0
end

function Gem:resetToOriginalPosition()
    self.x = self._originalX
    self.y = self._originalY
end

function Gem:update(delta)
    if self._state == "selected" then
        self:updateDraggedPosition(delta)
    end
end

function Gem:updateDraggedPosition(delta)
    local targetCenterX, targetCenterY = self:calculateTargetCenter()
    local targetX, targetY = self:convertToTopLeftCoordinates(targetCenterX, targetCenterY)
    local clampedTargetX, clampedTargetY = self:clampTargetPosition(targetX, targetY)
    local angle = self:calculateMovementAngle(clampedTargetX, clampedTargetY)
    local distance = self:calculateMovementDistance(delta)

    self:moveGemInDirectionSector(angle, clampedTargetX, clampedTargetY, distance)
end

function Gem:calculateTargetCenter()
    local targetCenterX = self._mouseX - self._offsetX
    local targetCenterY = self._mouseY - self._offsetY
    return targetCenterX, targetCenterY
end

function Gem:convertToTopLeftCoordinates(centerX, centerY)
    local targetX = centerX - PADDING - (self.width / 2)
    local targetY = centerY - PADDING - (self.height / 2)
    return targetX, targetY
end

function Gem:clampTargetPosition(targetX, targetY)
    local maxMovementX = self.width
    local maxMovementY = self.height

    local maxX = self._originalX + maxMovementX
    local minX = self._originalX - maxMovementX
    local clampedX = math.max(minX, math.min(maxX, targetX))

    local maxY = self._originalY + maxMovementY
    local minY = self._originalY - maxMovementY
    local clampedY = math.max(minY, math.min(maxY, targetY))

    return clampedX, clampedY
end

function Gem:calculateMovementAngle(targetX, targetY)
    local vectorX = targetX - self._originalX
    local vectorY = targetY - self._originalY

    local angle = math.atan2(vectorY, vectorX)
    local degrees = (angle * 180 / math.pi)
    if degrees < 0 then degrees = degrees + 360 end

    return degrees
end

function Gem:calculateMovementDistance(delta)
    return MOVEMENT_SPEED * delta
end

function Gem:moveGemInDirectionSector(angleDegrees, targetX, targetY, distance)
    -- Consider movement more horizontal if the angle is closer to 0/180 than 90/270
    local normalizedAngle = angleDegrees % 180
    local isHorizontalSector = normalizedAngle < 45 or normalizedAngle > 135

    if isHorizontalSector then
        self:moveGemHorizontally(targetX, distance)
        self.y = self._originalY
    else
        self:moveGemVertically(targetY, distance)
        self.x = self._originalX
    end
end

function Gem:moveGemHorizontally(targetX, distance)
    if self.x < targetX then
        self.x = math.min(self.x + distance, targetX)
    elseif self.x > targetX then
        self.x = math.max(self.x - distance, targetX)
    end
end

function Gem:moveGemVertically(targetY, distance)
    if self.y < targetY then
        self.y = math.min(self.y + distance, targetY)
    elseif self.y > targetY then
        self.y = math.max(self.y - distance, targetY)
    end
end

function Gem:draw(graphics)
    self:setGemColor(graphics)
    self:drawGemCircle(graphics)
    self:resetGraphicsColor(graphics)
end

function Gem:setGemColor(graphics)
    local color = COLORS[self.color] or COLORS.default
    local r, g, b, a = color[1], color[2], color[3], color[4]
    graphics:setColor(r, g, b, a)
end

function Gem:drawGemCircle(graphics)
    local radius = math.min(self.width, self.height) / 2
    local visualX, visualY = self:getVisualPosition()
    local centerX = visualX + radius
    local centerY = visualY + radius
    graphics:circle("fill", centerX, centerY, radius)
end

function Gem:resetGraphicsColor(graphics)
    graphics:setColor(1, 1, 1, 1)
end

return Gem
