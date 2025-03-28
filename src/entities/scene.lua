local GameObject = require('src.entities.game_object')

local Scene = {}
Scene.__index = Scene

function Scene.new()
    local self = GameObject.new()
    setmetatable(self, Scene)
    self.gameObjects = {}
    return self
end

function Scene:addGameObject(gameObject)
    table.insert(self.gameObjects, gameObject)
end

function Scene:removeGameObject(gameObject)
    for i, obj in ipairs(self.gameObjects) do
        if obj == gameObject then
            table.remove(self.gameObjects, i)
            break
        end
    end
end

function Scene:getGameObjects()
    return self.gameObjects
end

function Scene:update(delta)
    for _, gameObject in ipairs(self.gameObjects) do
        if gameObject.update then
            gameObject:update(delta)
        end
    end
end

function Scene:draw(graphics)
    for _, gameObject in ipairs(self.gameObjects) do
        if gameObject.draw then
            gameObject:draw(graphics)
        end
    end
end

function Scene:mousepressed(x, y, button)
    for _, gameObject in ipairs(self.gameObjects) do
        if gameObject.onMousePressed then
            gameObject:onMousePressed(x, y)
        end
    end
end

function Scene:mousemoved(x, y, dx, dy)
    for _, gameObject in ipairs(self.gameObjects) do
        if gameObject.onMouseMoved then
            gameObject:onMouseMoved(x, y)
        end
    end
end

function Scene:mousereleased(x, y, button)
    for _, gameObject in ipairs(self.gameObjects) do
        if gameObject.onMouseReleased then
            gameObject:onMouseReleased(x, y)
        end
    end
end

return Scene 