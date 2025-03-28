local Board = {}
Board.__index = Board

local Animation = require("src.entities.animation")

-- Constants for board dimensions
local BOARD_WIDTH = 7
local BOARD_HEIGHT = 10
local CELL_SIZE = 50  -- Add this constant for cell size

function Board.new(randomFn)
    local self = setmetatable({}, Board)
    
    -- Initialize empty board
    self.cells = {}
    for x = 1, BOARD_WIDTH do
        self.cells[x] = {}
        for y = 1, BOARD_HEIGHT do
            self.cells[x][y] = nil
        end
    end
    
    -- Store random function or use love.math.random if available
    self.randomFn = randomFn or (love and love.math.random or math.random)
    
    -- Add selection tracking
    self.selectedGem = nil
    self.selectedX = nil
    self.selectedY = nil
    
    -- Replace old animation properties with new Animation instance
    self.currentAnimation = nil
    
    return self
end

function Board:getWidth()
    return BOARD_WIDTH
end

function Board:getHeight()
    return BOARD_HEIGHT
end

function Board:getCellSize()
    return CELL_SIZE
end

function Board:isValidPosition(x, y)
    return x >= 1 and x <= BOARD_WIDTH and y >= 1 and y <= BOARD_HEIGHT
end

function Board:getGem(x, y)
    if not self:isValidPosition(x, y) then
        return nil
    end
    return self.cells[x][y]
end

function Board:setGem(x, y, gem)
    if self:isValidPosition(x, y) then
        self.cells[x][y] = gem
        if gem then
            gem:setPosition(x, y)
        end
    end
end

function Board:createRandomGem()
    local Gem = require("src.entities.gem")
    local colors = Gem.getValidColors()
    local color = colors[self.randomFn(#colors)]
    return Gem.new({type = "regular", color = color})
end

function Board:isValidGemPlacement(x, y, gem)
    -- Check horizontal matches
    if x >= 3 then
        local gem1 = self:getGem(x-2, y)
        local gem2 = self:getGem(x-1, y)
        if gem1 and gem2 and gem1:getColor() == gem2:getColor() and gem2:getColor() == gem:getColor() then
            return false
        end
    end
    
    -- Check vertical matches
    if y >= 3 then
        local gem1 = self:getGem(x, y-2)
        local gem2 = self:getGem(x, y-1)
        if gem1 and gem2 and gem1:getColor() == gem2:getColor() and gem2:getColor() == gem:getColor() then
            return false
        end
    end
    
    return true
end

function Board:fillWithGems()
    for x = 1, BOARD_WIDTH do
        for y = 1, BOARD_HEIGHT do
            local gem
            local attempts = 0
            local maxAttempts = 10
            
            repeat
                gem = self:createRandomGem()
                attempts = attempts + 1
            until self:isValidGemPlacement(x, y, gem) or attempts >= maxAttempts
            
            self:setGem(x, y, gem)
        end
    end
end

function Board:selectGem(x, y)
    if self:isValidPosition(x, y) then
        self.selectedGem = self:getGem(x, y)
        self.selectedX = x
        self.selectedY = y
        if self.selectedGem then
            self.selectedGem:setSelected(true)
            self.selectedX = x
        end
    end
end

function Board:updateGemPosition(offsetX)
    if not self.selectedGem then return end
    
    -- Limit movement to one cell width in either direction
    local maxOffset = CELL_SIZE
    offsetX = math.max(-maxOffset, math.min(maxOffset, offsetX))
    
    -- Calculate new visual position
    local visualX = self.selectedX + (offsetX / CELL_SIZE)
    
    -- Round to 2 decimal places to avoid floating-point precision issues
    visualX = math.floor(visualX * 100) / 100
    
    -- Update only the visual position, keeping grid position intact
    self.selectedGem:setVisualPosition(visualX, self.selectedY)
end

function Board:update(dt)
    -- Handle gem return animation
    if self.currentAnimation and self.animatingGem then
        self.currentAnimation:update(dt)
        
        -- Update gem position
        local newX = self.currentAnimation:getCurrentValue()
        local _, gridY = self.animatingGem:getPosition()
        self.animatingGem:setVisualPosition(newX, gridY)
        
        -- Check if animation is complete
        if self.currentAnimation:isComplete() then
            -- Ensure final position is exactly on grid
            local finalX, _ = self.animatingGem:getPosition()
            self.animatingGem:setVisualPosition(finalX, gridY)
            self.animatingGem = nil
            self.currentAnimation = nil
        end
    end
end

function Board:releaseGem()
    if self.selectedGem then
        -- Create new animation for gem return
        local visualX, _ = self.selectedGem:getVisualPosition()
        self.currentAnimation = Animation.new({
            startValue = visualX,
            endValue = self.selectedX,
            duration = 0.2 -- Keep same duration as before
        })
        
        self.selectedGem:setSelected(false)
        self.animatingGem = self.selectedGem -- Keep track of which gem is animating
        self.selectedGem = nil
        self.selectedX = nil
        self.selectedY = nil
    end
end

function Board:draw(offsetX, offsetY, cellSize)
    -- Draw board background
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle(
        "fill", 
        offsetX - 5, 
        offsetY - 5, 
        self:getWidth() * cellSize + 10, 
        self:getHeight() * cellSize + 10
    )

    -- Draw board grid
    love.graphics.setColor(0.3, 0.3, 0.3)
    for x = 0, self:getWidth() do
        love.graphics.line(
            offsetX + x * cellSize,
            offsetY,
            offsetX + x * cellSize,
            offsetY + self:getHeight() * cellSize
        )
    end
    
    for y = 0, self:getHeight() do
        love.graphics.line(
            offsetX,
            offsetY + y * cellSize,
            offsetX + self:getWidth() * cellSize,
            offsetY + y * cellSize
        )
    end

    -- Draw cells and non-selected/non-animating gems first
    for x = 1, self:getWidth() do
        for y = 1, self:getHeight() do
            -- Draw cell background
            love.graphics.setColor(0.15, 0.15, 0.15)
            love.graphics.rectangle(
                "fill",
                offsetX + (x-1) * cellSize,
                offsetY + (y-1) * cellSize,
                cellSize,
                cellSize
            )

            -- Draw gem if present and not selected/animating
            local gem = self:getGem(x, y)
            if gem and gem ~= self.selectedGem and gem ~= self.animatingGem then
                local visualX, visualY = gem:getVisualPosition()
                gem:draw(
                    offsetX + (visualX-1) * cellSize,
                    offsetY + (visualY-1) * cellSize,
                    cellSize
                )
            end
        end
    end

    -- Draw animating gem if exists
    if self.animatingGem then
        local visualX, visualY = self.animatingGem:getVisualPosition()
        self.animatingGem:draw(
            offsetX + (visualX-1) * cellSize,
            offsetY + (visualY-1) * cellSize,
            cellSize
        )
    end

    -- Draw selected gem last (on top)
    if self.selectedGem then
        local visualX, visualY = self.selectedGem:getVisualPosition()
        self.selectedGem:draw(
            offsetX + (visualX-1) * cellSize,
            offsetY + (visualY-1) * cellSize,
            cellSize
        )
    end

    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

return Board 