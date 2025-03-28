local Board = require("src.entities.board")

-- Game state
local board
local CELL_SIZE = 50
local BOARD_OFFSET_X = 100
local BOARD_OFFSET_Y = 50

function love.load()
    -- Initialize game state
    board = Board.new()
end

function love.update(dt)
    -- Update game logic here
end

function love.draw()
    -- Draw board background
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle(
        "fill", 
        BOARD_OFFSET_X - 5, 
        BOARD_OFFSET_Y - 5, 
        board:getWidth() * CELL_SIZE + 10, 
        board:getHeight() * CELL_SIZE + 10
    )

    -- Draw board grid
    love.graphics.setColor(0.3, 0.3, 0.3)
    for x = 0, board:getWidth() do
        love.graphics.line(
            BOARD_OFFSET_X + x * CELL_SIZE,
            BOARD_OFFSET_Y,
            BOARD_OFFSET_X + x * CELL_SIZE,
            BOARD_OFFSET_Y + board:getHeight() * CELL_SIZE
        )
    end
    
    for y = 0, board:getHeight() do
        love.graphics.line(
            BOARD_OFFSET_X,
            BOARD_OFFSET_Y + y * CELL_SIZE,
            BOARD_OFFSET_X + board:getWidth() * CELL_SIZE,
            BOARD_OFFSET_Y + y * CELL_SIZE
        )
    end

    -- Draw cells
    for x = 1, board:getWidth() do
        for y = 1, board:getHeight() do
            -- Draw cell background
            love.graphics.setColor(0.15, 0.15, 0.15)
            love.graphics.rectangle(
                "fill",
                BOARD_OFFSET_X + (x-1) * CELL_SIZE,
                BOARD_OFFSET_Y + (y-1) * CELL_SIZE,
                CELL_SIZE,
                CELL_SIZE
            )
        end
    end

    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end 