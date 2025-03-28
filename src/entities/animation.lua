local Animation = {}
Animation.__index = Animation

-- Default linear easing function
local function linearEasing(t)
    return t
end

function Animation.new(config)
    local self = setmetatable({}, Animation)
    
    -- Validate and store configuration
    assert(type(config.startValue) == "number", "startValue must be a number")
    assert(type(config.endValue) == "number", "endValue must be a number")
    assert(type(config.duration) == "number", "duration must be a number")
    
    self.startValue = config.startValue
    self.endValue = config.endValue
    self.duration = config.duration
    self.easingFn = config.easingFn or linearEasing
    
    -- Initialize animation state
    self.currentTime = 0
    self.currentValue = self.startValue
    self.isFinished = false
    
    return self
end

function Animation:update(dt)
    if self.isFinished then return end
    
    self.currentTime = self.currentTime + dt
    local progress = math.min(self.currentTime / self.duration, 1)
    
    -- Apply easing function to progress
    local easedProgress = self.easingFn(progress)
    
    -- Calculate current value using linear interpolation
    self.currentValue = self.startValue + (self.endValue - self.startValue) * easedProgress
    
    -- Check if animation is complete
    if progress >= 1 then
        self.currentValue = self.endValue -- Ensure we end exactly at target
        self.isFinished = true
    end
end

function Animation:getCurrentValue()
    return self.currentValue
end

function Animation:getDuration()
    return self.duration
end

function Animation:isComplete()
    return self.isFinished
end

-- Optional: Add method to reset animation
function Animation:reset()
    self.currentTime = 0
    self.currentValue = self.startValue
    self.isFinished = false
end

return Animation 