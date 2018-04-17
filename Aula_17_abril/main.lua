function love.load()
  x = 50 y = 200
  w = 200 h = 150
  mqtt = require("mqtt_library")
  mqtt_client  = mqtt.client.create("test.mosquitto.org",                                     1883, callback)
  mqtt_client:connect("1320966")
  mqtt_client:subscribe("movimentos")
  
end

function callback(topic,  payload)
  local mx, my = love.mouse.getPosition() 
  local Pkey,Px,Py = split(payload,",")
  
  if Pkey == 'b' and naimagem (mx,my, Px, Py) then
    y = 200
  end
  if Pkey == "down" and naimagem(mx, my, Px, Py) then
    y = y + 10
  end
end

function naimagem (mx, my, x, y) 
  return (mx>x) and (mx<x+w) and (my>y) and (my<y+h)
end

function love.keypressed(key)
  mqtt_client:publish("movimentos",key..","..x..
                                    ","..y)
end

function love.update (dt)
  mqtt_client:handler()
end

function love.draw ()
  love.graphics.rectangle("line", x, y, w, h)
end
