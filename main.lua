app = require("app")

lurker = require("lurker")
lurker.postswap = function()
  app.reload()
end

function love.load()
  app.once()
  app.load()
end

function love.update(dt)
  lurker.update()
  app.update(dt)
end

function love.draw()
  app.draw()
end

function love.resize(w, h)
  app.resize(w, h)
end
