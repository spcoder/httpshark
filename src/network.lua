local socket = require "socket"

local udp = socket.udp()

udp:settimeout(0)
udp:setsockname('127.0.0.1', 7991)

local stop
repeat
  data, msg = udp:receive()
  if data then
    love.thread.getChannel("response"):push(data)
  elseif msg ~= 'timeout' then
    print("receive error: " .. tostring(msg))
  end
  socket.sleep(0.01)
  stop = love.thread.getChannel("net.stop"):pop()
until stop

udp:close()
love.thread.getChannel("net.close"):supply("closed")
