require('spec.love_mock')
local Main = require('src.main')
local BoardScene = require('src.entities.board_scene')
local GraphicsWrapper = require('src.graphics.graphics_wrapper')
local BackgroundGrid = require('src.graphics.background_grid')

describe('Main Game', function()
    local main
    local graphics

    before_each(function()
        -- Mock love.graphics.getDimensions
        _G.love.graphics.getDimensions = function() return 800, 600 end
        
        -- Mock love.keyboard.isDown
        _G.love.keyboard.isDown = function(key) return false end
        
        main = Main.new()
        graphics = GraphicsWrapper.new()
    end)

    it('should initialize with a board scene', function()
        local gameObjects = main.boardScene:getGameObjects()
        assert.equals(360, #gameObjects) -- 8 * 45 gems
    end)
    
    it('should initialize with an infinite background grid', function()
        assert.is_not_nil(main.backgroundGrid)
        assert.equals(50, main.backgroundGrid:getCellWidth())
        assert.equals(50, main.backgroundGrid:getCellHeight())
        assert.equals(0, main.backgroundGrid.cameraX)
        assert.equals(0, main.backgroundGrid.cameraY)
    end)
    
    it('should move camera with arrow keys', function()
        -- Mock arrow key being pressed
        _G.love.keyboard.isDown = function(key)
            if key == "right" then return true end
            return false
        end
        
        -- Update with 0.5 second delta time
        main:update(0.5)
        
        -- Camera should have moved right at the specified speed
        assert.is_true(main.cameraX > 0)
        assert.equals(0, main.cameraY)
        
        -- The grid's camera position should be updated
        assert.equals(main.cameraX, main.backgroundGrid.cameraX)
        assert.equals(main.cameraY, main.backgroundGrid.cameraY)
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