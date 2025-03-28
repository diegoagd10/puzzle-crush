local Board = {}
Board.__index = Board

-- Constants for board dimensions
local BOARD_WIDTH = 7
local BOARD_HEIGHT = 10

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
    
    return self
end

function Board:getWidth()
    return BOARD_WIDTH
end

function Board:getHeight()
    return BOARD_HEIGHT
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

    -- Draw cells and gems
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

            -- Draw gem if present
            local gem = self:getGem(x, y)
            if gem then
                gem:draw(
                    offsetX + (x-1) * cellSize,
                    offsetY + (y-1) * cellSize,
                    cellSize
                )
            end
        end
    end

    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

return Board 