SCREEN_WIDTH = 320
SCREEN_HEIGHT = 480
MAX_METEORS = 12

plane = {
  src = "imagens/plane.png",
  width = 64,
  height = 64,
  x = SCREEN_WIDTH / 2 -32,
  y = SCREEN_HEIGHT - 64
    
}

meteors = {}

function removeMeteors()
  for i = #meteors, 1, -1 do
    if meteors[i].y > SCREEN_HEIGHT then
      table.remove( meteors, i )
    end
    if meteors[i].x > SCREEN_WIDTH or meteors[i].x < -50 then
      table.remove( meteors, i )
    end  
  end
end
function createMeteor()
  meteor = {
    x = math.random( SCREEN_WIDTH ),
    y = -70,
    weight = math.random(3),
    horizontal_movement = math.random( -1, 1 )
  }
  table.insert( meteors, meteor )
end  

function moveMeteors()
  for k,meteor in pairs( meteors ) do
    meteor.y = meteor.y + meteor.weight
    meteor.x = meteor.x + meteor.horizontal_movement 
  end
end

function movePlane()
  if love.keyboard.isDown("w") then
      plane.y = plane.y - 1
  end
  if love.keyboard.isDown("s") then
    plane.y = plane.y + 1
  end  
  if love.keyboard.isDown("a") then
    plane.x = plane.x - 1
  end  
  if love.keyboard.isDown("d") then
    plane.x = plane.x + 1
  end 
end

-- Load some default values for our rectangle.
function love.load()
  love.window.setMode( SCREEN_WIDTH , SCREEN_HEIGHT, {resizable = false} )
  love.window.setTitle( "14bis vs Meteoros" )
  math.randomseed( os.time() )
  background_img = love.graphics.newImage("imagens/background.png")
  meteor_img = love.graphics.newImage("imagens/meteor.png")
  plane.image = love.graphics.newImage( plane.src )
  
end

-- Increase the size of the rectangle every frame.
function love.update(dt)
  if love.keyboard.isDown( "w", "a", "s", "d" ) then
    movePlane()
  end
  
  removeMeteors()
  
  if #meteors < MAX_METEORS then
    createMeteor()
  end
  
  moveMeteors()

  
end

-- Draw a coloured rectangle.
function love.draw()
  love.graphics.draw( background_img, 0, 0 )
  love.graphics.draw( plane.image, plane.x, plane.y )
  
  for k,meteor in pairs(meteors) do
    love.graphics.draw( meteor_img, meteor.x, meteor.y )
  end
end