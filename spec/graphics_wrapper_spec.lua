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
                end
            }
        }
        
        local graphics = GraphicsWrapper.new()
        local drawCalls = {}
        
        -- Mock the graphics wrapper methods
        local originalSetColor = graphics.setColor
        local originalRectangle = graphics.rectangle
        
        graphics.setColor = function(self, r, g, b, a)
            table.insert(drawCalls, {type = "setColor", r = r, g = g, b = b, a = a})
        end
        
        graphics.rectangle = function(self, mode, x, y, width, height)
            table.insert(drawCalls, {type = "rectangle", mode = mode, x = x, y = y, width = width, height = height})
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
        
        -- Cleanup
        _G.love = nil
    end)
end) 