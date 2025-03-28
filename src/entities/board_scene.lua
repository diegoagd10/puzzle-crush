local Scene = require('src.entities.scene')
local Gem = require('src.entities.gem')

local BoardScene = {}
BoardScene.__index = BoardScene

-- Set up inheritance from Scene
setmetatable(BoardScene, {__index = Scene})

-- Constants
local GEM_SIZE = 40
local BOARD_WIDTH = 8
local BOARD_HEIGHT = 45
local COLORS = {'red', 'blue', 'green', 'yellow', 'purple', 'orange'}

function BoardScene.new()
    local self = Scene.new()
    setmetatable(self, BoardScene)
    self:initializeBoard()
    return self
end

function BoardScene:initializeBoard()
    for row = 0, BOARD_HEIGHT - 1 do
        for col = 0, BOARD_WIDTH - 1 do
            local gem = Gem.new()
            gem:setDimensions(GEM_SIZE, GEM_SIZE)
            gem:setGridPosition(col, row)
            
            -- Set random color
            local randomColor = COLORS[love.math.random(#COLORS)]
            gem:setColor(randomColor)
            gem:setType(randomColor)
            
            self:addGameObject(gem)
        end
    end
end

return BoardScene 