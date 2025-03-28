local GraphicsWrapper = {}
GraphicsWrapper.__index = GraphicsWrapper

function GraphicsWrapper.new()
    local self = setmetatable({}, GraphicsWrapper)
    return self
end

function GraphicsWrapper:setColor(r, g, b, a)
    love.graphics.setColor(r, g, b, a)
end

function GraphicsWrapper:rectangle(mode, x, y, width, height)
    love.graphics.rectangle(mode, x, y, width, height)
end

return GraphicsWrapper 