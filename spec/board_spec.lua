local Board = require("src.entities.board")

describe("Board", function()
    describe("Creation", function()
        it("should create an empty 7x10 board", function()
            local board = Board.new()
            assert.are.equal(7, board:getWidth())
            assert.are.equal(10, board:getHeight())
        end)

        it("should initialize all cells as empty", function()
            local board = Board.new()
            for x = 1, board:getWidth() do
                for y = 1, board:getHeight() do
                    assert.is_nil(board:getGem(x, y))
                end
            end
        end)
    end)

    describe("Boundary checks", function()
        local board

        before_each(function()
            board = Board.new()
        end)

        it("should return nil for out of bounds coordinates (negative)", function()
            assert.is_nil(board:getGem(0, 1))
            assert.is_nil(board:getGem(1, 0))
            assert.is_nil(board:getGem(-1, -1))
        end)

        it("should return nil for out of bounds coordinates (exceeding)", function()
            assert.is_nil(board:getGem(8, 1))
            assert.is_nil(board:getGem(1, 11))
            assert.is_nil(board:getGem(8, 11))
        end)

        it("should validate coordinates", function()
            assert.is_false(board:isValidPosition(0, 1))
            assert.is_false(board:isValidPosition(1, 0))
            assert.is_false(board:isValidPosition(8, 1))
            assert.is_false(board:isValidPosition(1, 11))
            assert.is_true(board:isValidPosition(1, 1))
            assert.is_true(board:isValidPosition(7, 10))
        end)
    end)

    describe("Filling the board", function()
        local board
        local currentIndex = 0
        local deterministicRandom = function(max)
            currentIndex = currentIndex + 1
            return currentIndex % max + 1
        end

        before_each(function()
            currentIndex = 0
            board = Board.new(deterministicRandom)
        end)

        it("should fill the board with random gems", function()
            board:fillWithGems()
            
            for x = 1, board:getWidth() do
                for y = 1, board:getHeight() do
                    local gem = board:getGem(x, y)
                    assert.is_not_nil(gem)
                    assert.are.equal("regular", gem:getType())
                    assert.is_not_nil(gem:getColor())
                end
            end
        end)

        it("should not create matches when filling the board", function()
            board:fillWithGems()
            
            -- Check horizontal matches
            for y = 1, board:getHeight() do
                for x = 1, board:getWidth() - 2 do
                    local gem1 = board:getGem(x, y)
                    local gem2 = board:getGem(x + 1, y)
                    local gem3 = board:getGem(x + 2, y)
                    
                    assert.is_false(
                        gem1:getColor() == gem2:getColor() and 
                        gem2:getColor() == gem3:getColor(),
                        "Found horizontal match at (" .. x .. "," .. y .. ")"
                    )
                end
            end
            
            -- Check vertical matches
            for x = 1, board:getWidth() do
                for y = 1, board:getHeight() - 2 do
                    local gem1 = board:getGem(x, y)
                    local gem2 = board:getGem(x, y + 1)
                    local gem3 = board:getGem(x, y + 2)
                    
                    assert.is_false(
                        gem1:getColor() == gem2:getColor() and 
                        gem2:getColor() == gem3:getColor(),
                        "Found vertical match at (" .. x .. "," .. y .. ")"
                    )
                end
            end
        end)
    end)

    describe("Gem movement", function()
        local board
        
        before_each(function()
            board = Board.new()
            board:fillWithGems()
        end)

        it("should track selected gem position", function()
            -- Select gem at position (2,1)
            local originalGem = board:getGem(2, 1)
            board:selectGem(2, 1)
            
            -- Move it horizontally (simulate drag)
            board:updateGemPosition(50) -- 50 pixels to the right
            
            -- Check positions after movement
            local currentX, currentY = originalGem:getVisualPosition()
            local gridX, gridY = originalGem:getPosition()
            
            assert.are.equal(2, gridX, "Grid X position should remain unchanged")
            assert.are.equal(1, gridY, "Grid Y position should remain unchanged")
            assert.are_not.equal(2, currentX, "Visual X position should change")
            assert.are.equal(1, currentY, "Visual Y position should remain unchanged")
            
            -- Release gem and run animation
            board:releaseGem()
            board:update(0.2)
            
            -- Check final positions
            local finalX, finalY = originalGem:getVisualPosition()
            assert.are.equal(2, finalX, "Visual X position should return to original")
            assert.are.equal(1, finalY, "Visual Y position should remain unchanged")
        end)

        it("should limit horizontal movement to one cell width", function()
            local originalGem = board:getGem(2, 1)
            board:selectGem(2, 1)
            
            -- Try to move too far right
            board:updateGemPosition(100) -- More than one cell width
            
            local currentX, _ = originalGem:getVisualPosition()
            local maxOffset = board:getCellSize() -- Assuming cell size is available
            
            assert.is_true(currentX <= 3) -- Should not move more than one cell
        end)

        it("should animate gem return to original position when moved right", function()
            -- Select and move gem
            local originalGem = board:getGem(2, 1)
            board:selectGem(2, 1)
            board:updateGemPosition(50) -- Move 50 pixels right
            
            -- Start return animation
            board:releaseGem()
            
            -- Get initial animation position
            local startX, _ = originalGem:getVisualPosition()
            
            -- Update halfway through animation (0.1 seconds with 0.2 total duration)
            board:update(0.1)
            
            -- Check intermediate position (should be halfway back)
            local midX, _ = originalGem:getVisualPosition()
            assert.is_true(midX < startX)
            assert.is_true(midX > 2)
            
            -- Complete animation
            board:update(0.1)
            
            -- Verify final position
            local finalX, finalY = originalGem:getVisualPosition()
            assert.are.equal(2, finalX)
            assert.are.equal(1, finalY)
        end)

        it("should animate gem return to original position when moved left", function()
            -- Select and move gem
            local originalGem = board:getGem(2, 1)
            board:selectGem(2, 1)
            board:updateGemPosition(-50) -- Move 50 pixels left
            
            -- Start return animation
            board:releaseGem()
            
            -- Get initial animation position
            local startX, _ = originalGem:getVisualPosition()
            
            -- Update halfway through animation (0.1 seconds with 0.2 total duration)
            board:update(0.1)
            
            -- Check intermediate position (should be halfway back)
            local midX, _ = originalGem:getVisualPosition()
            assert.is_true(midX > startX)
            assert.is_true(midX < 2)
            
            -- Complete animation
            board:update(0.1)
            
            -- Verify final position
            local finalX, finalY = originalGem:getVisualPosition()
            assert.are.equal(2, finalX)
            assert.are.equal(1, finalY)
        end)

        it("should maintain gem visibility during animation", function()
            local originalGem = board:getGem(2, 1)
            board:selectGem(2, 1)
            board:updateGemPosition(50)
            
            board:releaseGem()
            assert.is_not_nil(originalGem:getVisualPosition())
            
            board:update(0.1)
            local midX, midY = originalGem:getVisualPosition()
            assert.is_not_nil(midX)
            assert.is_not_nil(midY)
            
            board:update(0.1)
            local finalX, finalY = originalGem:getVisualPosition()
            assert.is_not_nil(finalX)
            assert.is_not_nil(finalY)
        end)
    end)
end) 