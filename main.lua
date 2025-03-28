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
    
    -- Store initial mouse position
    mouseX = 0
    mouseY = 0
    initialMouseX = 0
    dragStarted = false
end

function love.update(dt)
    if dragStarted then
        -- Calculate drag offset
        local dragOffset = mouseX - initialMouseX
        board:updateGemPosition(dragOffset)
    end
    
    -- Update board animations
    board:update(dt)
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then  -- Left mouse button
        mouseX = x
        initialMouseX = x
        
        -- Convert mouse position to board coordinates
        local boardX = math.floor((x - BOARD_OFFSET_X) / CELL_SIZE) + 1
        local boardY = math.floor((y - BOARD_OFFSET_Y) / CELL_SIZE) + 1
        
        if board:isValidPosition(boardX, boardY) then
            board:selectGem(boardX, boardY)
            dragStarted = true
        end
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    mouseX = x
end

function love.mousereleased(x, y, button, istouch, presses)
    if button == 1 then  -- Left mouse button
        dragStarted = false
        board:releaseGem()
    end
end

function love.draw()
    board:draw(BOARD_OFFSET_X, BOARD_OFFSET_Y, CELL_SIZE)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end 