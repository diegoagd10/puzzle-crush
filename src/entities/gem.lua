local Gem = {}
Gem.__index = Gem

-- Valid gem types and colors
local VALID_TYPES = {
    regular = true,
    tnt = true,
    fan = true,
    drill = true,
    rainbow = true
}

local VALID_COLORS = {
    red = true,
    blue = true,
    green = true,
    yellow = true,
    purple = true
}

local VALID_DIRECTIONS = {
    horizontal = true,
    vertical = true
}

function Gem.getValidColors()
    local colors = {}
    for color, _ in pairs(VALID_COLORS) do
        table.insert(colors, color)
    end
    return colors
end

function Gem.new(config)
    if not config.type or not VALID_TYPES[config.type] then
        error("Invalid gem type: " .. (config.type or "nil"))
    end

    if config.type == "regular" then
        if not config.color or not VALID_COLORS[config.color] then
            error("Invalid color: " .. (config.color or "nil"))
        end
    end

    if (config.type == "fan" or config.type == "drill") and 
       (not config.direction or not VALID_DIRECTIONS[config.direction]) then
        error("Invalid direction for " .. config.type .. ": " .. (config.direction or "nil"))
    end

    local self = setmetatable({}, Gem)
    self.type = config.type
    self.color = config.color
    self.direction = config.direction
    self.x = nil
    self.y = nil
    self.visualX = nil
    self.visualY = nil
    self.matched = false
    self.selected = false
    
    return self
end

function Gem:getType()
    return self.type
end

function Gem:getColor()
    return self.color
end

function Gem:getDirection()
    return self.direction
end

function Gem:setPosition(x, y)
    self.x = x
    self.y = y
    -- Initialize visual position to match grid position
    if not self.visualX then
        self.visualX = x
    end
    if not self.visualY then
        self.visualY = y
    end
end

function Gem:getPosition()
    return self.x, self.y
end

function Gem:getVisualPosition()
    return self.visualX or self.x, self.visualY or self.y
end

function Gem:setVisualPosition(x, y)
    self.visualX = x
    self.visualY = y
end

function Gem:isMultiColor()
    return self.type == "rainbow"
end

function Gem:setMatched(value)
    self.matched = value
end

function Gem:isMatched()
    return self.matched
end

function Gem:setSelected(value)
    self.selected = value
end

function Gem:isSelected()
    return self.selected
end

function Gem:draw(x, y, cellSize)
    local color = self:getColor()
    if color == "red" then
        love.graphics.setColor(1, 0, 0)
    elseif color == "blue" then
        love.graphics.setColor(0, 0, 1)
    elseif color == "green" then
        love.graphics.setColor(0, 1, 0)
    elseif color == "yellow" then
        love.graphics.setColor(1, 1, 0)
    elseif color == "purple" then
        love.graphics.setColor(1, 0, 1)
    end
    
    love.graphics.circle(
        "fill",
        x + cellSize/2,
        y + cellSize/2,
        cellSize/2 - 2
    )
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

return Gem 