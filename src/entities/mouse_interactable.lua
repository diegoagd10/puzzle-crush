local MouseInteractable = {}
MouseInteractable.__index = MouseInteractable

function MouseInteractable.new()
    local self = setmetatable({}, MouseInteractable)
    return self
end

function MouseInteractable:onMousePressed()
    error("onMousePressed must be implemented by interactable object")
end

function MouseInteractable:onMouseReleased()
    error("onMouseReleased must be implemented by interactable object")
end

return MouseInteractable 