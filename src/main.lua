local Main = {}
Main.__index = Main

local Gem = require('src.entities.gem')
local GraphicsWrapper = require('src.graphics.graphics_wrapper')

function Main.new()
    local self = setmetatable({}, Main)
    self.graphics = GraphicsWrapper.new()
    self.gem = Gem.new()
    
    -- Initialize the gem
    self.gem:setPosition(100, 100)
    self.gem:setDimensions(50, 50)
    self.gem:setColor('red')
    
    return self
end

function Main:update(dt)
    self.gem:update(dt)
end

function Main:draw()
    self.gem:draw(self.graphics)
end

function Main:mousepressed(x, y, button)
    self.gem:onMousePressed(x, y)
end

function Main:mousemoved(x, y, dx, dy)
    self.gem:onMouseMoved(x, y)
end

function Main:mousereleased(x, y, button)
    self.gem:onMouseReleased(x, y)
end

return Main 