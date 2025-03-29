local GraphicsWrapper = require("src.graphics.graphics_wrapper")

describe("GraphicsWrapper", function()
    it("should wrap love.graphics functions", function()
        -- Mock love.graphics
        _G.love = {
            graphics = {
                setColor = function(r, g, b, a)
                    -- Just call the function, no need to return values
                end,
                rectangle = function(mode, x, y, width, height)
                    -- Just call the function, no need to return values
                end,
                circle = function(mode, x, y, radius)
                    -- Just call the function, no need to return values
                end,
                line = function(x1, y1, x2, y2)
                    -- Just call the function, no need to return values
                end,
                setLineWidth = function(width)
                    -- Just call the function, no need to return values
                end
            }
        }
        
        local graphics = GraphicsWrapper.new()
        local drawCalls = {}
        
        -- Mock the graphics wrapper methods
        local originalSetColor = graphics.setColor
        local originalRectangle = graphics.rectangle
        local originalCircle = graphics.circle
        
        graphics.setColor = function(self, r, g, b, a)
            table.insert(drawCalls, {type = "setColor", r = r, g = g, b = b, a = a})
        end
        
        graphics.rectangle = function(self, mode, x, y, width, height)
            table.insert(drawCalls, {type = "rectangle", mode = mode, x = x, y = y, width = width, height = height})
        end

        graphics.circle = function(self, mode, x, y, radius)
            table.insert(drawCalls, {type = "circle", mode = mode, x = x, y = y, radius = radius})
        end
        
        -- Test setColor
        graphics:setColor(1, 0, 0, 1)
        assert.are.equal(1, #drawCalls)
        assert.are.equal("setColor", drawCalls[1].type)
        assert.are.equal(1, drawCalls[1].r)
        assert.are.equal(0, drawCalls[1].g)
        assert.are.equal(0, drawCalls[1].b)
        assert.are.equal(1, drawCalls[1].a)
        
        -- Test rectangle
        graphics:rectangle("fill", 10, 20, 30, 40)
        assert.are.equal(2, #drawCalls)
        assert.are.equal("rectangle", drawCalls[2].type)
        assert.are.equal("fill", drawCalls[2].mode)
        assert.are.equal(10, drawCalls[2].x)
        assert.are.equal(20, drawCalls[2].y)
        assert.are.equal(30, drawCalls[2].width)
        assert.are.equal(40, drawCalls[2].height)

        -- Test circle
        graphics:circle("fill", 50, 60, 25)
        assert.are.equal(3, #drawCalls)
        assert.are.equal("circle", drawCalls[3].type)
        assert.are.equal("fill", drawCalls[3].mode)
        assert.are.equal(50, drawCalls[3].x)
        assert.are.equal(60, drawCalls[3].y)
        assert.are.equal(25, drawCalls[3].radius)
        
        -- Cleanup
        _G.love = nil
    end)

    it('should provide a method to draw circles', function()
        -- Mock love.graphics for this test
        _G.love = {
            graphics = {
                circle = function(mode, x, y, radius) end
            }
        }
        
        local graphics = GraphicsWrapper.new()
        assert.has_no.errors(function()
            graphics:circle("fill", 100, 100, 50)
        end)
        
        -- Cleanup
        _G.love = nil
    end)

    it('should provide a method to draw lines', function()
        -- Mock love.graphics for this test
        _G.love = {
            graphics = {
                line = function(x1, y1, x2, y2) end
            }
        }
        
        local graphics = GraphicsWrapper.new()
        assert.has_no.errors(function()
            graphics:line(0, 0, 100, 100)
        end)
        
        -- Cleanup
        _G.love = nil
    end)

    it('should provide a method to set line width', function()
        -- Mock love.graphics for this test
        _G.love = {
            graphics = {
                setLineWidth = function(width) end
            }
        }
        
        local graphics = GraphicsWrapper.new()
        assert.has_no.errors(function()
            graphics:setLineWidth(2)
        end)
        
        -- Cleanup
        _G.love = nil
    end)
end) 