local Scene = require("src.entities.scene")
local Gem = require("src.entities.gem")
local GraphicsWrapper = require("src.graphics.graphics_wrapper")

describe("Scene", function()
    local scene
    local gem
    local graphics

    before_each(function()
        scene = Scene.new()
        gem = Gem.new()
        graphics = GraphicsWrapper.new()
    end)

    it("should initialize with empty game objects list", function()
        assert.are.equal(0, #scene:getGameObjects())
    end)

    it("should add game objects", function()
        scene:addGameObject(gem)
        assert.are.equal(1, #scene:getGameObjects())
        assert.are.equal(gem, scene:getGameObjects()[1])
    end)

    it("should remove game objects", function()
        scene:addGameObject(gem)
        scene:removeGameObject(gem)
        assert.are.equal(0, #scene:getGameObjects())
    end)

    it("should update all game objects", function()
        scene:addGameObject(gem)
        gem:setPosition(0, 0)
        gem:setDimensions(50, 50)
        
        -- Select and move the gem
        gem:onMousePressed(30, 30)  -- Account for padding
        gem:onMouseMoved(100, 0)
        
        -- Update scene
        scene:update(0.5)
        assert.are.equal(50, gem.x)  -- Limited by maximum allowed movement (width = 50)
        local visualX = gem:getVisualPosition()
        assert.are.equal(55, visualX)  -- Visual position includes padding
    end)

    it("should draw all game objects", function()
        scene:addGameObject(gem)
        gem:setPosition(10, 20)
        gem:setDimensions(50, 50)
        gem:setColor("red")
        
        -- Create graphics wrapper with mocked functions
        local drawCalls = {}
        local graphics = GraphicsWrapper.new()
        
        -- Mock the graphics wrapper methods
        local originalSetColor = graphics.setColor
        local originalCircle = graphics.circle
        
        graphics.setColor = function(self, r, g, b, a)
            table.insert(drawCalls, {type = "setColor", r = r, g = g, b = b, a = a})
        end
        
        graphics.circle = function(self, mode, x, y, radius)
            table.insert(drawCalls, {type = "circle", mode = mode, x = x, y = y, radius = radius})
        end
        
        -- Draw the scene
        scene:draw(graphics)
        
        -- Restore original methods
        graphics.setColor = originalSetColor
        graphics.circle = originalCircle
        
        -- Verify draw calls
        assert.are.equal(3, #drawCalls)  -- Two setColor calls and one circle call
        
        -- Verify first color was set to red
        assert.are.equal("setColor", drawCalls[1].type)
        assert.are.equal(1, drawCalls[1].r)
        assert.are.equal(0, drawCalls[1].g)
        assert.are.equal(0, drawCalls[1].b)
        assert.are.equal(1, drawCalls[1].a)
        
        -- Verify circle was drawn at correct position and size (accounting for padding)
        assert.are.equal("circle", drawCalls[2].type)
        assert.are.equal("fill", drawCalls[2].mode)
        assert.are.equal(40, drawCalls[2].x)  -- centerX = (10 + 5) + 25 (radius)
        assert.are.equal(50, drawCalls[2].y)  -- centerY = (20 + 5) + 25 (radius)
        assert.are.equal(25, drawCalls[2].radius)  -- radius = min(50, 50) / 2
        
        -- Verify color was reset to white
        assert.are.equal("setColor", drawCalls[3].type)
        assert.are.equal(1, drawCalls[3].r)
        assert.are.equal(1, drawCalls[3].g)
        assert.are.equal(1, drawCalls[3].b)
        assert.are.equal(1, drawCalls[3].a)
    end)

    it("should handle mouse events for all game objects", function()
        scene:addGameObject(gem)
        gem:setPosition(0, 0)
        gem:setDimensions(50, 50)
        
        -- Mouse press inside gem (accounting for padding)
        scene:mousepressed(30, 30, 1)
        assert.are.equal("selected", gem:getState())
        
        -- Mouse move
        scene:mousemoved(100, 0, 70, 0)
        scene:update(0.5)
        assert.are.equal(50, gem.x)  -- Limited by maximum allowed movement (width = 50)
        local visualX = gem:getVisualPosition()
        assert.are.equal(55, visualX)  -- Visual position includes padding
        
        -- Mouse release
        scene:mousereleased(100, 0, 1)
        assert.are.equal("idle", gem:getState())
    end)
end) 