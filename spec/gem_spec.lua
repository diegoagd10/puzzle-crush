local Gem = require("src.entities.gem")
local GameObject = require("src.entities.game_object")
local MouseInteractable = require("src.entities.mouse_interactable")
local GraphicsWrapper = require("src.graphics.graphics_wrapper")

describe("Gem", function()
    it("should extend from GameObject and implement MouseInteractable", function()
        local gem = Gem.new()
        local gemMetatable = getmetatable(gem)
        local gemClassMetatable = getmetatable(Gem)
        local parentMetatable = getmetatable(gemClassMetatable)
        
        print("Gem metatable:", gemMetatable)
        print("Gem class metatable:", gemClassMetatable)
        print("Parent metatable:", parentMetatable)
        
        assert.is_true(gemMetatable.__index == Gem)
        assert.is_true(gemClassMetatable.__index == GameObject)
        assert.is_true(parentMetatable.__index == MouseInteractable)
    end)

    it("should initialize with default properties", function()
        local gem = Gem.new()
        assert.are.equal(0, gem.x)
        assert.are.equal(0, gem.y)
        assert.are.equal(0, gem.width)
        assert.are.equal(0, gem.height)
        assert.is_nil(gem.color)
        assert.is_nil(gem.type)
        assert.are.equal("idle", gem:getState())
    end)

    it("should set and get position", function()
        local gem = Gem.new()
        gem:setPosition(10, 20)
        local x, y = gem:getPosition()
        assert.are.equal(10, x)
        assert.are.equal(20, y)
    end)

    it("should set and get dimensions", function()
        local gem = Gem.new()
        gem:setDimensions(30, 40)
        assert.are.equal(30, gem.width)
        assert.are.equal(40, gem.height)
    end)

    it("should set and get color", function()
        local gem = Gem.new()
        gem:setColor("red")
        assert.are.equal("red", gem:getColor())
    end)

    it("should set and get type", function()
        local gem = Gem.new()
        gem:setType("regular")
        assert.are.equal("regular", gem:getType())
    end)

    it("should change state when notified of mouse events", function()
        local gem = Gem.new()
        gem:setPosition(0, 0)
        gem:setDimensions(50, 50)
        
        assert.are.equal("idle", gem:getState())
        
        gem:onMousePressed(25, 25)  -- Mouse inside gem
        assert.are.equal("selected", gem:getState())
        
        gem:onMouseReleased(25, 25)
        assert.are.equal("idle", gem:getState())
    end)

    it("should move smoothly towards mouse position when selected", function()
        local gem = Gem.new()
        gem:setPosition(0, 0)
        gem:setDimensions(50, 50)
        
        -- Select the gem and set initial mouse position
        gem:onMousePressed(25, 25)
        assert.are.equal("selected", gem:getState())
        
        -- Set target position
        gem:onMouseMoved(100, 0)
        
        -- Move for 0.5 seconds
        gem:update(0.5)
        assert.are.equal(75, gem.x)  -- Should move to target (100) minus half width (25)
        
        -- Move for another 0.5 seconds
        gem:update(0.5)
        assert.are.equal(75, gem.x)  -- Should maintain target position
    end)

    it("should not move when not selected", function()
        local gem = Gem.new()
        gem:setPosition(0, 0)
        
        -- Update mouse position while not selected
        gem:onMouseMoved(100, 0)
        gem:update(0.5)
        assert.are.equal(0, gem.x)
    end)

    it("should maintain position when released", function()
        local gem = Gem.new()
        gem:setPosition(0, 0)
        gem:setDimensions(50, 50)
        
        -- Select and move
        gem:onMousePressed(25, 25)
        gem:onMouseMoved(100, 0)
        gem:update(1.0)  -- Move for 1 second
        assert.are.equal(75, gem.x)  -- Should reach target
        
        -- Release and update
        gem:onMouseReleased(100, 0)
        gem:update(0.5)
        assert.are.equal(75, gem.x)  -- Should maintain position
    end)

    it("should only change state to selected when mouse is over the gem", function()
        local gem = Gem.new()
        gem:setPosition(0, 0)
        gem:setDimensions(50, 50)
        
        -- Mouse press outside gem
        gem:onMousePressed(75, 25)
        assert.are.equal("idle", gem:getState())
        
        -- Mouse press inside gem
        gem:onMousePressed(25, 25)
        assert.are.equal("selected", gem:getState())
    end)

    it("should detect if mouse is over the gem", function()
        local gem = Gem.new()
        gem:setPosition(0, 0)
        gem:setDimensions(50, 50)
        
        -- Mouse inside gem
        assert.is_true(gem:isMouseOver(25, 25))
        
        -- Mouse outside gem
        assert.is_false(gem:isMouseOver(75, 25))  -- outside right
        assert.is_false(gem:isMouseOver(25, 75))  -- outside bottom
        assert.is_false(gem:isMouseOver(-25, 25)) -- outside left
        assert.is_false(gem:isMouseOver(25, -25)) -- outside top
    end)

    it("should draw itself with the correct color and dimensions", function()
        local gem = Gem.new()
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
        
        -- Draw the gem
        gem:draw(graphics)
        
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
        
        -- Verify circle was drawn at correct position and size
        assert.are.equal("circle", drawCalls[2].type)
        assert.are.equal("fill", drawCalls[2].mode)
        assert.are.equal(35, drawCalls[2].x)  -- centerX = 10 + 25 (radius)
        assert.are.equal(45, drawCalls[2].y)  -- centerY = 20 + 25 (radius)
        assert.are.equal(25, drawCalls[2].radius)  -- radius = min(50, 50) / 2
        
        -- Verify color was reset to white
        assert.are.equal("setColor", drawCalls[3].type)
        assert.are.equal(1, drawCalls[3].r)
        assert.are.equal(1, drawCalls[3].g)
        assert.are.equal(1, drawCalls[3].b)
        assert.are.equal(1, drawCalls[3].a)
    end)
end) 