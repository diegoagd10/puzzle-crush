require('spec.love_mock')
local BoardScene = require('src.entities.board_scene')

describe('BoardScene', function()
    local boardScene

    before_each(function()
        boardScene = BoardScene.new()
    end)

    describe('creation', function()
        it('should create a board with correct dimensions', function()
            local gameObjects = boardScene:getGameObjects()
            assert.equals(360, #gameObjects) -- 8 * 45 gems
        end)

        it('should initialize gems with valid colors', function()
            local gameObjects = boardScene:getGameObjects()
            for _, gem in ipairs(gameObjects) do
                assert.is_not_nil(gem:getColor())
                assert.is_not_nil(gem:getType())
            end
        end)

        it('should position gems in a grid', function()
            local gameObjects = boardScene:getGameObjects()
            local firstGem = gameObjects[1]
            local secondGem = gameObjects[2]
            local lastGem = gameObjects[360]

            -- Gem size is 40x40 pixels
            assert.equals(0, firstGem.x)
            assert.equals(0, firstGem.y)
            assert.equals(45, secondGem.x)  -- 40 + 5 padding
            assert.equals(0, secondGem.y)
            assert.equals(315, lastGem.x)   -- (8-1) * 45
            assert.equals(1980, lastGem.y)  -- (45-1) * 45
        end)
    end)
end) 