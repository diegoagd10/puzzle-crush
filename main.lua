local Main = require('src.main')

local game

function love.load()
    game = Main.new()
end

function love.update(dt)
    game:update(dt)
end

function love.mousepressed(x, y, button, istouch, presses)
    game:mousepressed(x, y, button)
end

function love.mousemoved(x, y, dx, dy, istouch)
    game:mousemoved(x, y, dx, dy)
end

function love.mousereleased(x, y, button, istouch, presses)
    game:mousereleased(x, y, button)
end

function love.draw()
    game:draw()
end