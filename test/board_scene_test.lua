local BoardScene = require('src.entities.board_scene')

describe('BoardScene', function()
    local boardScene

    beforeEach(function()
        boardScene = BoardScene.new()
    end)

    describe('creation', function()
        it('should create a board with correct dimensions', function()
            local gameObjects = boardScene:getGameObjects()
            assert.equals(700, #gameObjects) -- 70 * 10 gems
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
            local lastGem = gameObjects[700]

            -- Assuming gem size is 50x50 pixels
            assert.equals(0, firstGem.x)
            assert.equals(0, firstGem.y)
            assert.equals(50, secondGem.x)
            assert.equals(0, secondGem.y)
            assert.equals(3450, lastGem.x) -- (70-1) * 50
            assert.equals(450, lastGem.y)  -- (10-1) * 50
        end)
    end)
end) 