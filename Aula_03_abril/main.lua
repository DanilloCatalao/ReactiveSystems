function love.load()
  arrayRet = 
  {
    retangulo (50, 200, 200, 150),
    retangulo (200, 50, 150, 200),
    retangulo (100, 30, 100, 220),
    retangulo (400, 540, 150, 200),
    retangulo (450, 200, 150, 100),
    retangulo (600, 100, 30, 200)
  }
end


function love.keypressed(key)
  if key == 'b' then
    for i = 1, #arrayRet do
      arrayRet[i]:keypressed("b")
    end 
  end
  
  if key == "down" then
     for i = 1, #arrayRet do
      arrayRet[i]:keypressed("down")
    end 
  end
  
  if key == "right" then
   for i = 1, #arrayRet do
      arrayRet[i]:keypressed("right")
    end 
  end
  
  if key == "up" then
     for i = 1, #arrayRet do
      arrayRet[i]:keypressed("up")
    end 
  end
  
  if key == "left" then
     for i = 1, #arrayRet do
      arrayRet[i]:keypressed("left")
    end 
  end
  
end

function love.update (dt)
  
end

function love.draw ()
  for i = 1, #arrayRet do
    arrayRet[i].draw()
  end
end

function retangulo (x,y,w,h)
  local originalx, originaly, rx, ry, rw, rh = 
  x, y, x, y, w, h
  
  return {
    naimagem = 
      function (mx, my, x, y) 
        return (mx>x) and (mx<x+rw) and (my>y) and (my<y+rh)
      end,
    
    draw =
      function ()
        love.graphics.rectangle("line", rx, ry, rw, rh)
      end,
      
    keypressed =
    function (self,key)
      local mx, my = love.mouse.getPosition(self)
      if key == "down" and self.naimagem(mx, my, rx, ry)  then
        ry = ry + 10
      end
      if key == "right" and self.naimagem(mx, my, rx, ry)  then
        rx = rx + 10
      end
      if key == "up" and self.naimagem(mx, my, rx, ry)  then
        ry = ry - 10
      end
      if key == "left" and self.naimagem(mx, my, rx, ry)  then
        rx = rx - 10
      end
      if key == "b" and self.naimagem(mx, my, rx, ry)  then
        ry = 0
        rx = 0
      end
      
    end
  }
end
