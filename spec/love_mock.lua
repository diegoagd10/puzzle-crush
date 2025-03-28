-- Mock LÖVE framework for testing
love = {
    graphics = {
        getWidth = function() return 800 end,
        getHeight = function() return 600 end,
        setColor = function() end,
        circle = function() end,
        rectangle = function() end,
        draw = function() end,
        print = function() end,
        newImage = function() return {} end
    },
    window = {
        getMode = function() return 800, 600 end
    },
    mouse = {
        getPosition = function() return 0, 0 end,
        isDown = function() return false end
    },
    keyboard = {
        isDown = function() return false end
    },
    timer = {
        getDelta = function() return 0.016 end -- 60 FPS
    },
    math = {
        random = function(max) return math.random(max) end,
        randomseed = function(seed) math.randomseed(seed) end
    }
}

-- Set a fixed random seed for reproducible tests
math.randomseed(12345) 