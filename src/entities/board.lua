local Board = {}
Board.__index = Board

-- Constants for board dimensions
local BOARD_WIDTH = 7
local BOARD_HEIGHT = 10

function Board.new()
    local self = setmetatable({}, Board)
    
    -- Initialize empty board
    self.cells = {}
    for x = 1, BOARD_WIDTH do
        self.cells[x] = {}
        for y = 1, BOARD_HEIGHT do
            self.cells[x][y] = nil
        end
    end
    
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

return Board 