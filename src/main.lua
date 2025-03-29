local Main = {}
Main.__index = Main

local BoardScene = require('src.entities.board_scene')
local GraphicsWrapper = require('src.graphics.graphics_wrapper')
local BackgroundGrid = require('src.graphics.background_grid')

function Main.new()
    local self = setmetatable({}, Main)
    self.graphics = GraphicsWrapper.new()
    self.boardScene = BoardScene.new()
    
    -- Create the infinite background grid
    self.backgroundGrid = BackgroundGrid.new(50)
    
    -- Camera position and movement speed
    self.cameraX = 0
    self.cameraY = 0
    self.cameraSpeed = 200 -- pixels per second
    
    return self
end

function Main:update(dt)
    self.boardScene:update(dt)
    
    -- Handle camera movement with arrow keys
    if love.keyboard.isDown("left") then
        self.cameraX = self.cameraX - self.cameraSpeed * dt
    end
    if love.keyboard.isDown("right") then
        self.cameraX = self.cameraX + self.cameraSpeed * dt
    end
    if love.keyboard.isDown("up") then
        self.cameraY = self.cameraY - self.cameraSpeed * dt
    end
    if love.keyboard.isDown("down") then
        self.cameraY = self.cameraY + self.cameraSpeed * dt
    end
    
    -- Update the grid's camera position
    self.backgroundGrid:setCameraPosition(self.cameraX, self.cameraY)
end

function Main:draw()
    -- First draw the background grid
    self.backgroundGrid:draw(self.graphics)
    
    -- Then draw the board scene on top
    self.boardScene:draw(self.graphics)
end

function Main:mousepressed(x, y, button)
    self.boardScene:mousepressed(x, y, button)
end

function Main:mousemoved(x, y, dx, dy)
    self.boardScene:mousemoved(x, y, dx, dy)
end

function Main:mousereleased(x, y, button)
    self.boardScene:mousereleased(x, y, button)
end

return Main 