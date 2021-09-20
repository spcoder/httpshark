local table = require "table"
local tween = require "tween"
local app = {}
local ground = {}
local lanes = {}
local maxlane = 0
local font, fontHeight
local laneWidth = 25 -- TODO: make dynamic based on window
local pillHeight = 5 -- TODO: make dynamic based on window
local radians = (3 * math.pi) / 2
local net = { debug = {} }

function app.once()
  love.window.setDisplaySleepEnabled(true)
  love.graphics.setBackgroundColor(0, 0, 0)
  -- net server
  love.thread.newThread("network.lua"):start()
end

function app.quit()
  love.thread.getChannel("net.stop"):push("stop")
  local closed = love.thread.getChannel("net.close"):demand(5)
  print("socket: " .. (closed or "not closed"))
end

function addRequest(path)
  local lane = lanes[path]
  if not lane then
    lane = { col = maxlane, stackHeight = 0, path = path, requests = {} }
    lanes[path] = lane
    maxlane = maxlane + 1
  end
  table.insert(lane.requests, { rect = { y = 0 } })
end

function app.load()
  lanes = {}
  --font = love.graphics.newFont("superstar_memesbruh03.ttf", 14)
  font = love.graphics.newFont("editundo.ttf", 14)
  fontHeight = font:getHeight()
  ground = { height = 50 }
end

function app.reload()
  app.load()
end

function app.update(dt)
  local msg = love.thread.getChannel("net.debug"):pop()
  if msg == "net.debug.clear" then
    net.debug = {}
  elseif msg then
    print("text = " .. msg.text)
    table.insert(net.debug, msg)
  end

  -- requests
  local path = love.thread.getChannel("response"):pop()
  if path then
    addRequest(path)
  end

  -- pills
  local h = love.graphics.getHeight()
  for i in pairs(lanes) do
    local lane = lanes[i]
    local finishedRequests = {}
    for r = 1, #lane.requests do
      local request = lane.requests[r]
      request.tweener = request.tweener or tween.new(2, request.rect, { y = (h - ground.height - pillHeight - lane.stackHeight) }, "inCubic")
      if request.tweener:update(dt) then
        lane.stackHeight = lane.stackHeight + pillHeight
        table.insert(finishedRequests, r)
      end
    end
    for r = 1, #finishedRequests do
      table.remove(lane.requests, r)
    end
    if lane.stackHeight > h then
      lane.stackHeight = 0
    end
  end
end

function app.draw()
  local w, h = love.graphics.getWidth(), love.graphics.getHeight()
  love.graphics.setFont(font)
  -- lanes
  for i in pairs(lanes) do
    local textWidth = font:getWidth(i)
    local lane = lanes[i]
    love.graphics.setColor(15 / 255, 15 / 255, 15 / 255)
    love.graphics.rectangle("fill", lane.col * laneWidth, 0, laneWidth, h)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", lane.col * laneWidth, h - ground.height - lane.stackHeight, laneWidth, lane.stackHeight)
    love.graphics.setColor(100 / 255, 100 / 255, 100 / 255)
    love.graphics.print(i, (lane.col * laneWidth) + ((laneWidth / 2) - (fontHeight / 2)), (h / 2) + (textWidth / 2), radians)
  end
  -- pills
  love.graphics.setColor(1, 1, 1)
  for i in pairs(lanes) do
    local lane = lanes[i]
    for r in pairs(lane.requests) do
      local request = lane.requests[r]
      love.graphics.rectangle("fill", lane.col * laneWidth, request.rect.y, laneWidth, pillHeight)
    end
  end
  -- ground
  love.graphics.setColor(20 / 255, 20 / 255, 20 / 255)
  love.graphics.rectangle("fill", 0, h - ground.height, w, ground.height)
  -- debug
  y = 10
  love.graphics.setColor(1, 1, 1)
  for _, d in pairs(net.debug) do
    love.graphics.print(d.text, 150, y)
    y = y + 15
  end
end

function app.resize(w, h)
end

return app
