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
end) 