local Board = require("src.entities.board")

-- Game state
local board
local CELL_SIZE = 50
local BOARD_OFFSET_X = 100
local BOARD_OFFSET_Y = 50

function love.load()
    -- Initialize game state
    board = Board.new()
    board:fillWithGems()
end

function love.update(dt)
    -- Update game logic here
end

function love.draw()
    board:draw(BOARD_OFFSET_X, BOARD_OFFSET_Y, CELL_SIZE)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end 