local MouseInteractable = require("src.entities.mouse_interactable")

describe("MouseInteractable", function()
    it("should be a valid interface", function()
        local interactable = MouseInteractable.new()
        assert.is_true(interactable.onMousePressed ~= nil)
        assert.is_true(interactable.onMouseReleased ~= nil)
    end)
end) 