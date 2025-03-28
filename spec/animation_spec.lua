local Animation = require("src.entities.animation")

describe("Animation", function()
    it("should create a new animation with proper properties", function()
        local animation = Animation.new({
            startValue = 1,
            endValue = 10,
            duration = 0.5
        })
        
        assert.are.equal(1, animation:getCurrentValue())
        assert.are.equal(0.5, animation:getDuration())
        assert.is_false(animation:isComplete())
    end)

    it("should update animation progress correctly", function()
        local animation = Animation.new({
            startValue = 0,
            endValue = 100,
            duration = 1.0
        })

        animation:update(0.5) -- Half duration
        local value = animation:getCurrentValue()
        assert.is_true(value > 0 and value < 100)
        assert.is_false(animation:isComplete())

        animation:update(0.5) -- Complete duration
        assert.are.equal(100, animation:getCurrentValue())
        assert.is_true(animation:isComplete())
    end)

    it("should support different easing functions", function()
        local animation = Animation.new({
            startValue = 0,
            endValue = 100,
            duration = 1.0,
            easingFn = function(t) return t * t end -- Quadratic easing
        })

        animation:update(0.5)
        local value = animation:getCurrentValue()
        assert.are.equal(25, value) -- At t=0.5, quad easing should be 0.25 progress
    end)
end) 