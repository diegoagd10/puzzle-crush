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
end) 