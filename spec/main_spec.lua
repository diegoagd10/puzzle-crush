require('spec.love_mock')
local Main = require('src.main')
local BoardScene = require('src.entities.board_scene')
local GraphicsWrapper = require('src.graphics.graphics_wrapper')

describe('Main Game', function()
    local main
    local graphics

    before_each(function()
        main = Main.new()
        graphics = GraphicsWrapper.new()
    end)

    it('should initialize with a board scene', function()
        local gameObjects = main.boardScene:getGameObjects()
        assert.equals(360, #gameObjects) -- 8 * 45 gems
    end)

    it('should update and draw the board scene', function()
        -- Update the game
        main:update(0.1) -- Simulate 100ms update
        
        -- Draw the game
        main:draw()
        
        -- Verify that the board scene exists and has the correct number of gems
        assert.is_not_nil(main.boardScene)
        local gameObjects = main.boardScene:getGameObjects()
        assert.equals(360, #gameObjects) -- 8 * 45 gems
    end)
end) 