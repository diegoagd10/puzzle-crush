require('spec.love_mock')
local BackgroundGrid = require('src.graphics.background_grid')
local GraphicsWrapper = require('src.graphics.graphics_wrapper')

describe('BackgroundGrid', function()
    local backgroundGrid
    local graphics
    
    before_each(function()
        -- Mock love.graphics.getDimensions
        _G.love.graphics.getDimensions = function() return 800, 600 end
        
        graphics = GraphicsWrapper.new()
        backgroundGrid = BackgroundGrid.new()
    end)
    
    it('should calculate the correct number of visible columns and rows', function()
        local viewWidth, viewHeight = 800, 600
        assert.equals(math.ceil(viewWidth / 50) + 1, backgroundGrid:getColumnsCount(viewWidth))
        assert.equals(math.ceil(viewHeight / 50) + 1, backgroundGrid:getRowsCount(viewHeight))
    end)
    
    it('should have cells of 50x50 pixels by default', function()
        assert.equals(50, backgroundGrid:getCellWidth())
        assert.equals(50, backgroundGrid:getCellHeight())
    end)
    
    it('should have thicker grid lines for better visibility', function()
        assert.equals(2, backgroundGrid.gridLineWidth)
    end)
    
    it('should have camera position control', function()
        backgroundGrid:setCameraPosition(100, 200)
        assert.equals(100, backgroundGrid.cameraX)
        assert.equals(200, backgroundGrid.cameraY)
    end)
    
    it('should have a draw method that uses the graphics wrapper', function()
        -- We're just testing the method exists and doesn't error
        assert.has_no.errors(function()
            backgroundGrid:draw(graphics)
        end)
    end)
    
    it('should allow customizing the cell size', function()
        local customGrid = BackgroundGrid.new(20)
        assert.equals(20, customGrid:getCellWidth())
        assert.equals(20, customGrid:getCellHeight())
        
        local viewWidth, viewHeight = 800, 600
        assert.equals(math.ceil(viewWidth / 20) + 1, customGrid:getColumnsCount(viewWidth))
        assert.equals(math.ceil(viewHeight / 20) + 1, customGrid:getRowsCount(viewHeight))
    end)
end) 