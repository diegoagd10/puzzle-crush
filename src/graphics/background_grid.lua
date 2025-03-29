local BackgroundGrid = {}
BackgroundGrid.__index = BackgroundGrid

-- Create an infinite background grid
-- @param cellSize (optional) The size of each cell in pixels, defaults to 50
function BackgroundGrid.new(cellSize)
    local self = setmetatable({}, BackgroundGrid)
    
    self.cellSize = cellSize or 50
    
    -- Camera position (can be adjusted to "move" the grid)
    self.cameraX = 0
    self.cameraY = 0
    
    -- Colors for a comfortable eye experience
    self.backgroundColor = {r = 0.95, g = 0.95, b = 0.98, a = 1} -- Light bluish-white
    self.gridLineColor = {r = 0.8, g = 0.8, b = 0.85, a = 1} -- Soft gray-blue
    self.gridLineWidth = 2 -- Thicker lines for better visibility
    
    return self
end

function BackgroundGrid:getCellWidth()
    return self.cellSize
end

function BackgroundGrid:getCellHeight()
    return self.cellSize
end

function BackgroundGrid:getColumnsCount(viewWidth)
    -- This now returns the number of columns visible in the current view
    return math.ceil(viewWidth / self.cellSize) + 1
end

function BackgroundGrid:getRowsCount(viewHeight)
    -- This now returns the number of rows visible in the current view
    return math.ceil(viewHeight / self.cellSize) + 1
end

function BackgroundGrid:setCameraPosition(x, y)
    self.cameraX = x
    self.cameraY = y
end

function BackgroundGrid:draw(graphics)
    -- Get the current view dimensions
    local viewWidth, viewHeight = love.graphics.getDimensions()
    
    -- Draw background
    graphics:setColor(self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b, self.backgroundColor.a)
    graphics:rectangle("fill", 0, 0, viewWidth, viewHeight)
    
    -- Draw grid lines
    graphics:setColor(self.gridLineColor.r, self.gridLineColor.g, self.gridLineColor.b, self.gridLineColor.a)
    graphics:setLineWidth(self.gridLineWidth)
    
    -- Calculate the offset for the grid based on camera position
    local offsetX = self.cameraX % self.cellSize
    local offsetY = self.cameraY % self.cellSize
    
    -- Calculate the starting grid line position
    local startX = -offsetX
    local startY = -offsetY
    
    -- Draw vertical lines
    for i = 0, self:getColumnsCount(viewWidth) do
        local x = startX + (i * self.cellSize)
        graphics:line(x, 0, x, viewHeight)
    end
    
    -- Draw horizontal lines
    for i = 0, self:getRowsCount(viewHeight) do
        local y = startY + (i * self.cellSize)
        graphics:line(0, y, viewWidth, y)
    end
    
    -- Reset color
    graphics:setColor(1, 1, 1, 1)
end

return BackgroundGrid 