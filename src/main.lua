local Main = {}
Main.__index = Main

local BoardScene = require('src.entities.board_scene')
local GraphicsWrapper = require('src.graphics.graphics_wrapper')

function Main.new()
    local self = setmetatable({}, Main)
    self.graphics = GraphicsWrapper.new()
    self.boardScene = BoardScene.new()
    return self
end

function Main:update(dt)
    self.boardScene:update(dt)
end

function Main:draw()
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