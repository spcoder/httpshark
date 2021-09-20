function love.conf(t)
  t.version = "11.3"
  t.accelerometerjoystick = false
  t.window.title = "httpshark"
  t.window.icon = nil
  t.window.width = 800
  t.window.height = 600
  t.window.resizable = true
  t.window.minwidth = 600
  t.window.minheight = 400
  t.modules.audio = false
  t.modules.joystick = false
  t.modules.physics = false
  t.modules.sound = false
  t.modules.touch = false
  t.modules.video = false
end
