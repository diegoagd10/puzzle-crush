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

        assert.is_true(gemMetatable.__index == Gem)
        assert.is_true(gemClassMetatable.__index == GameObject)
        assert.is_true(parentMetatable.__index == MouseInteractable)
    end)

    it("should initialize with default properties", function()
        local gem = Gem.new()
        local x, y = gem:getPosition()
        assert.are.equal(0, x)
        assert.are.equal(0, y)
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

    it("should get visual position with padding", function()
        local gem = Gem.new()
        gem:setPosition(10, 20)
        local visualX, visualY = gem:getVisualPosition()
        assert.are.equal(15, visualX) -- 10 + 5 padding
        assert.are.equal(25, visualY) -- 20 + 5 padding
    end)

    it("should set and get grid position", function()
        local gem = Gem.new()
        gem:setDimensions(40, 40)
        gem:setGridPosition(1, 2)
        local x, y = gem:getPosition()
        assert.are.equal(45, x) -- 1 * (40 + 5)
        assert.are.equal(90, y) -- 2 * (40 + 5)
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

        -- Mouse inside gem (accounting for padding)
        gem:onMousePressed(30, 30) -- Mouse inside gem with padding
        assert.are.equal("selected", gem:getState())

        gem:onMouseReleased(30, 30)
        assert.are.equal("idle", gem:getState())
    end)

    it("should move smoothly towards mouse position when selected", function()
        local gem = Gem.new()
        gem:setPosition(0, 0)
        gem:setDimensions(50, 50)

        -- Select the gem and set initial mouse position
        gem:onMousePressed(30, 30) -- Account for padding
        assert.are.equal("selected", gem:getState())

        -- Set target position
        gem:onMouseMoved(100, 0)

        -- Move for 0.5 seconds
        gem:update(0.5)
        assert.are.equal(50, gem.x)   -- Should move to maximum allowed (50)
        local visualX = gem:getVisualPosition()
        assert.are.equal(55, visualX) -- Visual position includes padding
    end)

    it("should not move when not selected", function()
        local gem = Gem.new()
        gem:setPosition(0, 0)

        -- Update mouse position while not selected
        gem:onMouseMoved(100, 0)
        gem:update(0.5)
        assert.are.equal(0, gem.x)   -- Position shouldn't change
        local visualX = gem:getVisualPosition()
        assert.are.equal(5, visualX) -- Visual position includes padding
    end)

    it("should return to original position when released", function()
        local gem = Gem.new()
        gem:setPosition(0, 0)
        gem:setDimensions(50, 50)

        -- Select and move
        gem:onMousePressed(30, 30)  -- Account for padding
        gem:onMouseMoved(100, 0)
        gem:update(1.0)             -- Move for 1 second
        assert.are.equal(50, gem.x) -- Should reach maximum allowed (50)

        -- Release over invalid position (outside grid)
        gem:onMouseReleased(200, 0)
        gem:update(0.5)
        assert.are.equal(0, gem.x) -- Should return to original position
    end)

    it("should return to original position when original position is different from zero released", function()
        local gem = Gem.new()
        gem:setPosition(10, 10)
        gem:setDimensions(50, 50)

        -- Select and move
        gem:onMousePressed(30, 30)  -- Account for padding
        gem:onMouseMoved(100, 0)
        gem:update(1.0)             -- Move for 1 second
        assert.are.equal(60, gem.x) -- Should reach maximum allowed (10 + 50)

        -- Release over invalid position (outside grid)
        gem:onMouseReleased(200, 0)
        gem:update(0.5)
        assert.are.equal(10, gem.x) -- Should return to original position
    end)

    it("should only change state to selected when mouse is over the gem", function()
        local gem = Gem.new()
        gem:setPosition(0, 0)
        gem:setDimensions(50, 50)

        -- Mouse press outside gem
        gem:onMousePressed(80, 30)
        assert.are.equal("idle", gem:getState())

        -- Mouse press inside gem (accounting for padding)
        gem:onMousePressed(30, 30)
        assert.are.equal("selected", gem:getState())
    end)

    it("should detect if mouse is over the gem with padding", function()
        local gem = Gem.new()
        gem:setPosition(0, 0)
        gem:setDimensions(50, 50)

        -- Mouse inside gem (accounting for padding)
        assert.is_true(gem:isMouseOver(30, 30))

        -- Mouse outside gem
        assert.is_false(gem:isMouseOver(80, 30))  -- outside right
        assert.is_false(gem:isMouseOver(30, 80))  -- outside bottom
        assert.is_false(gem:isMouseOver(-20, 30)) -- outside left
        assert.is_false(gem:isMouseOver(30, -20)) -- outside top
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
            table.insert(drawCalls, { type = "setColor", r = r, g = g, b = b, a = a })
        end

        graphics.circle = function(self, mode, x, y, radius)
            table.insert(drawCalls, { type = "circle", mode = mode, x = x, y = y, radius = radius })
        end

        -- Draw the gem
        gem:draw(graphics)

        -- Restore original methods
        graphics.setColor = originalSetColor
        graphics.circle = originalCircle

        -- Verify draw calls
        assert.are.equal(3, #drawCalls) -- Two setColor calls and one circle call

        -- Verify first color was set to red
        assert.are.equal("setColor", drawCalls[1].type)
        assert.are.equal(1, drawCalls[1].r)
        assert.are.equal(0, drawCalls[1].g)
        assert.are.equal(0, drawCalls[1].b)
        assert.are.equal(1, drawCalls[1].a)

        -- Verify circle was drawn at correct position and size (accounting for padding)
        assert.are.equal("circle", drawCalls[2].type)
        assert.are.equal("fill", drawCalls[2].mode)
        assert.are.equal(40, drawCalls[2].x)      -- centerX = (10 + 5) + 25 (radius)
        assert.are.equal(50, drawCalls[2].y)      -- centerY = (20 + 5) + 25 (radius)
        assert.are.equal(25, drawCalls[2].radius) -- radius = min(50, 50) / 2

        -- Verify color was reset to white
        assert.are.equal("setColor", drawCalls[3].type)
        assert.are.equal(1, drawCalls[3].r)
        assert.are.equal(1, drawCalls[3].g)
        assert.are.equal(1, drawCalls[3].b)
        assert.are.equal(1, drawCalls[3].a)
    end)

    it("should limit movement to twice the gem's width", function()
        local gem = Gem.new()
        gem:setPosition(0, 0)
        gem:setDimensions(50, 50)

        -- Select the gem
        gem:onMousePressed(30, 30)
        assert.are.equal("selected", gem:getState())

        -- Try to move beyond the limit to the right
        gem:onMouseMoved(200, 0)    -- This would be beyond 1x width (50)
        gem:update(1.0)
        assert.are.equal(50, gem.x) -- Should be limited to 1x width (50)

        -- Try to move beyond the limit to the left
        gem:onMouseMoved(-100, 0)    -- This would be beyond 1x width to the left
        gem:update(1.0)
        assert.are.equal(-50, gem.x) -- Should be limited to -1x width (-50)
    end)

    it("should move vertically when gem is selected and mouse moves vertically", function()
        local gem = Gem.new()
        gem:setPosition(0, 0)
        gem:setDimensions(50, 50)

        -- Select the gem at center position
        -- The center of gem is at (25, 25) when accounting for padding and dimensions
        gem:onMousePressed(25, 25)
        assert.are.equal("selected", gem:getState())

        -- Move mouse vertically only, keeping X at center position
        gem:onMouseMoved(25, 100)
        gem:update(1.0)
        assert.are.equal(0, gem.x)  -- X position unchanged
        assert.are.equal(50, gem.y) -- Y position should move up to height limit

        -- Move mouse vertically in opposite direction, keeping X at center position
        gem:onMouseMoved(25, -50)
        gem:update(1.0)
        assert.are.equal(0, gem.x)   -- X position unchanged
        assert.are.equal(-50, gem.y) -- Y position should move down to negative height limit
    end)

    it("should restrict movement to either horizontal or vertical, not both", function()
        local gem = Gem.new()
        gem:setPosition(0, 0)
        gem:setDimensions(50, 50)

        -- Select the gem at center position
        gem:onMousePressed(25, 25)
        assert.are.equal("selected", gem:getState())

        -- Move mouse diagonally at 30 degrees (should result in horizontal movement)
        -- cos(30) = 0.866, sin(30) = 0.5, so we'll move more in X than Y
        gem:onMouseMoved(80, 50)
        gem:update(1.0)

        -- Should move only horizontally
        assert.are.equal(50, gem.x)
        assert.are.equal(0, gem.y)

        -- Reset position and selection
        gem:onMouseReleased(0, 0)  -- Release to reset state
        gem:setPosition(0, 0)      -- Reset position
        gem:onMousePressed(25, 25) -- Select again

        -- Move mouse diagonally at 60 degrees (should result in vertical movement)
        -- cos(60) = 0.5, sin(60) = 0.866, so we'll move more in Y than X
        gem:onMouseMoved(50, 80)
        gem:update(1.0)

        -- Should move only vertically
        assert.are.equal(0, gem.x)
        assert.are.equal(50, gem.y)
    end)

    it("should not move when clicked off-center", function()
        local gem = Gem.new()
        gem:setPosition(0, 0)
        gem:setDimensions(50, 50)

        -- Position is initially at origin
        assert.are.equal(0, gem.x)
        assert.are.equal(0, gem.y)

        -- Click on the gem at a point offset from center
        -- Center is at (25 + 5, 25 + 5) = (30, 30)
        -- Clicking at (10, 10) creates an offset of (-20, -20)
        gem:onMousePressed(10, 10)
        assert.are.equal("selected", gem:getState())

        -- Update without moving the mouse
        gem:update(1.0)

        -- Gem should not move just from being clicked off-center
        assert.are.equal(0, gem.x)
        assert.are.equal(0, gem.y)

        -- Now move the mouse while maintaining the same offset from center
        gem:onMouseMoved(60, 10) -- Move 50 pixels right, 0 vertical
        gem:update(1.0)

        -- Should move horizontally (angle is 0 degrees)
        assert.are.equal(50, gem.x) -- Moves to the max horizontal position
        assert.are.equal(0, gem.y)  -- No vertical movement
    end)

    describe("calculateMovementAngle", function()
        local gem

        before_each(function()
            gem = Gem.new()
            gem:setPosition(100, 100)
            gem._originalX = 100 -- Set original position for angle calculation
            gem._originalY = 100
        end)

        it("should calculate correct angle for upward movement", function()
            local angle = gem:calculateMovementAngle(100, 50) -- Moving up 50 pixels
            assert.are.equal(270, angle)                      -- Should point upward (270 degrees)
        end)

        it("should calculate correct angle for right movement", function()
            local angle = gem:calculateMovementAngle(150, 100) -- Moving right 50 pixels
            assert.are.equal(0, angle)                         -- Should point right (0 degrees)
        end)

        it("should calculate correct angle for diagonal movement", function()
            local angle = gem:calculateMovementAngle(150, 50) -- Moving up and right
            assert.are.equal(315, angle)                      -- Should point up-right (315 degrees)
        end)

        it("should calculate correct angle for downward movement", function()
            local angle = gem:calculateMovementAngle(100, 150) -- Moving down 50 pixels
            assert.are.equal(90, angle)                        -- Should point downward (90 degrees)
        end)

        it("should calculate correct angle for left movement", function()
            local angle = gem:calculateMovementAngle(50, 100) -- Moving left 50 pixels
            assert.are.equal(180, angle)                      -- Should point left (180 degrees)
        end)
    end)
end)
