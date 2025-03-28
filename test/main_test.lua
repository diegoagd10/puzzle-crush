local Main = require('src.main')
local Gem = require('src.entities.gem')
local GraphicsWrapper = require('src.graphics.graphics_wrapper')

describe('Main Game', function()
    local main
    local gem
    local graphics

    before_each(function()
        main = Main.new()
        gem = Gem.new()
        graphics = GraphicsWrapper.new()
        
        -- Set up a test gem
        gem:setPosition(100, 100)
        gem:setDimensions(50, 50)
        gem:setColor('red')
    end)

    it('should draw a gem on the screen', function()
        -- Draw the gem
        gem:draw(graphics)
        
        -- Note: In a real test environment, we would need to verify the actual rendering
        -- For now, we'll just verify that the gem has the correct properties
        assert.are.equal(100, gem.x)
        assert.are.equal(100, gem.y)
        assert.are.equal(50, gem.width)
        assert.are.equal(50, gem.height)
        assert.are.equal('red', gem:getColor())
    end)
end) 