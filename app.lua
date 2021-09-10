local table = require "table"
local app = {}
local ground = {}
local lanes = {}
local maxlane = 0
local font, fontHeight
local laneWidth = 25 -- TODO: make dynamic
local pillHeight = 5 -- TODO: make dynamic
local radians = (3 * math.pi) / 2

function app.once()
  love.window.setDisplaySleepEnabled(true)
  love.window.setMode(650, 650, { resizable = true, minwidth = 600, minheight = 400 })
  love.window.setTitle("httpshark")
  love.graphics.setBackgroundColor(0, 0, 0)
end

function simulateRequest(path)
  local lane = lanes[path]
  if not lane then
    lane = { col = maxlane, stackHeight = 0, path = path, requests = {} }
    lanes[path] = lane
    maxlane = maxlane + 1
  end
  table.insert(lane.requests, { y = 0 })
end

local threadCode = [[
local timer = require "love.timer"
local math = require "love.math"
local paths = {"GET /v1/account/14", "GET /v1/widget/test", "POST /v1/policy/43", "GET /v1/quote/888/detail"}
while true do
  local t = love.math.random(1, 16) * 0.25
  local p = paths[love.math.random(4)]
  timer.sleep(t)
  love.thread.getChannel("request"):push(p)
end
]]

function app.load()
  font = love.graphics.newFont("VCR_OSD_MONO_1.001.ttf", 13)
  fontHeight = font:getHeight()
  ground = { height = 50 }
  -- trigger thread
  thread = love.thread.newThread(threadCode)
  thread:start()
end

function app.reload()
  app.load()
end

function app.update(dt)
  local path = love.thread.getChannel("request"):pop()
  if path then
    simulateRequest(path)
  end
  -- pills
  local h = love.graphics.getHeight()
  for i in pairs(lanes) do
    local lane = lanes[i]
    for r in pairs(lane.requests) do
      local request = lane.requests[r]
      local y = request.y + (dt * 200)
      if y < h - ground.height - pillHeight - lane.stackHeight then
        -- TODO: don't be linear
        request.y = y
      else
        lane.stackHeight = lane.stackHeight + pillHeight
        lane.requests[r] = nil
      end
    end
  end
end

function app.draw()
  local w, h = love.graphics.getWidth(), love.graphics.getHeight()
  love.graphics.setFont(font)
  -- ground
  love.graphics.setColor(20 / 255, 20 / 255, 20 / 255)
  love.graphics.rectangle("fill", 0, h - ground.height, w, ground.height)
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
      love.graphics.rectangle("fill", lane.col * laneWidth, request.y, laneWidth, pillHeight)
    end
  end
end

function app.resize(w, h)
end

return app
