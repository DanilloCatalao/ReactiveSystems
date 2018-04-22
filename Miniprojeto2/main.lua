SCREEN_WIDTH = 320
SCREEN_HEIGHT = 480
MAX_METEORS = 18
METEORS_HIT = 0

function newPlane()
  local x, y = SCREEN_WIDTH / 2 - 32, SCREEN_HEIGHT - 64
  local width, height = 55, 55
  local img = plane_img
  return{
    shots = {},
    getX = function()
      return x
    end,
    getY = function()
      return y
    end,
    getWidth = function()
      return width
    end,
    getHeight = function()
      return height
    end,  
    movePlane = function( key )
      if key == "w" then
        y = y - 3
      end
      if key == "s" then
        y = y + 3
      end  
      if key == "a" then
        x = x - 3
      end  
      if key == "d" then
        x = x + 3
      end 
    end, 
     
    draw = function()
      love.graphics.draw( img, x, y )
    end
    
  }  
end

function shootAction()
  shoot_sound:play()
  local shoot = {
    x = plane.x + plane.width / 2 - 5,
    y = plane.y,
    width = 16,
    height = 16
  }
  table.insert( plane.shots, shoot )
end

function moveShots()
  for i = #plane.shots,1,-1 do
    if plane.shots[i].y > 0 then
      plane.shots[i].y = plane.shots[i].y - 3
    else
      table.remove( plane.shots, i )
    end  
  end  
end

function destroyPlane()
  plane_destruction_sound:play()
  plane.src = "imagens/explosion_plane.png"
  plane.image = love.graphics.newImage( plane.src )
  plane.width = 67
  plane.height = 77
end  
function hasCollision( x1, y1, l1, a1, x2, y2, l2, a2)
  return x2 < x1 + l1 and
         x1 < x2 + l2 and
         y1 < y2 + a2 and
         y2 < y1 + a1
end

function createMeteor( speed )
  local x, y = math.random( SCREEN_WIDTH ), -70
  local width, height = 35, 35
  local horizontal_movement = math.random( -1, 1 )
  local img = meteor_imgs[ math.random( 4 ) ] 
  local isActiveAfter = 0
  local wait = function (time)
    isActiveAfter = now + time
    coroutine.yield()
  end
  return {
    getX = function()
      return x
    end,
    getY = function()
      return y
    end,
    getWidth = function()
      return width
    end,
    getHeight = function()
      return height
    end, 
    update = coroutine.wrap( function(this) 
      while(1) do
        y = y + 1
        x = x + horizontal_movement
        wait( speed/100 )
      end
    end),    
    isActive = function()
      return now > isActiveAfter
    end,
    draw = function()
      love.graphics.draw( img, x, y )
    end  
  }
end  

function updateMeteors()
  for _,meteor in pairs( meteors ) do
    if meteor.isActive() then
      meteor.update()
    end  
  end
end

function removeMeteors()
  for i = #meteors, 1, -1 do
    if meteors[i].getY() > SCREEN_HEIGHT then
      table.remove( meteors, i )
    end
    if meteors[i].getX() > SCREEN_WIDTH or meteors[i].getX() < -50 then
      table.remove( meteors, i )
    end  
  end
end

function checkCollisionPlaneMeteor()
  for k,meteor in pairs(meteors) do
    if hasCollision( meteor.getX(), meteor.getY(), meteor.getWidth(), meteor.getHeight(), 
                     plane.getX(), plane.getY(), plane.getWidth(), plane.getHeight() ) then
      changeMusic()               
      destroyPlane() 
      GAME_OVER = true
    end
  end
end

function checkCollisionShotMeteor()
  for i = #plane.shots, 1, -1 do
    for j = #meteors, 1, -1 do
      if hasCollision( plane.shots[i].x, plane.shots[i].y,
                      plane.shots[i].width, plane.shots[i].height,
                      meteors[j].x, meteors[j].y,
                      meteors[j].width, meteors[j].height) then
        METEORS_HIT = METEORS_HIT + 1
        meteor_destruction_sound:stop()
        meteor_destruction_sound:play()
        table.remove( plane.shots, i )
        table.remove( meteors, j )
        break
      end  
    end
  end  
end  

function checkCollisions()
  checkCollisionPlaneMeteor()
  checkCollisionShotMeteor()
end  

function changeMusic() 
  environment_music:stop()
  --game_over_music:play()
end  

-- Load some default values for our rectangle.
function love.load()
  love.window.setMode( SCREEN_WIDTH , SCREEN_HEIGHT, {resizable = false} )
  love.window.setTitle( "Miniprojeto Love" )
  math.randomseed( os.time() )
  
  plane_img = love.graphics.newImage( "imagens/plane.png" )
  background_img = love.graphics.newImage( "imagens/background.png" )
  game_over_img = love.graphics.newImage( "imagens/gameover.png" )
  meteor_img_1 = love.graphics.newImage( "imagens/meteor1.png" )
  meteor_img_2 = love.graphics.newImage( "imagens/meteor2.png" )
  meteor_img_3 = love.graphics.newImage( "imagens/meteor3.png" )
  meteor_img_4 = love.graphics.newImage( "imagens/meteor4.png" )
  meteor_imgs = { meteor_img_1, meteor_img_2, meteor_img_3, meteor_img_4}
  shoot_img = love.graphics.newImage( "imagens/shoot.png" )
  environment_music = love.audio.newSource( "audios/environment.wav", "static" )
  environment_music:setLooping(true)
  environment_music:play()
  game_over_music = love.audio.newSource( "audios/game_over.wav", "static" )
  plane_destruction_sound = love.audio.newSource( "audios/plane_destruction.wav", "static" )
  meteor_destruction_sound = love.audio.newSource( "audios/meteor_destruction.wav", "static" )
  shoot_sound = love.audio.newSource( "audios/shoot.wav", "static" )
  
  plane = newPlane()
  meteors = {}
end

shot_limit = {false,false,false,false,false,true}
shot_limit_index = 0
-- Increase the size of the rectangle every frame.
function love.update(dt)
  now = os.clock()
  if not GAME_OVER then
    if love.keyboard.isDown( "escape" ) then
      love.event.quit()
    end
    if love.keyboard.isDown( "w") then
      plane.movePlane("w")
    end
    if love.keyboard.isDown( "s") then
      plane.movePlane("s")
    end
    if love.keyboard.isDown( "a") then
      plane.movePlane("a")
    end
    if love.keyboard.isDown( "d") then
      plane.movePlane("d")
    end
    if love.keyboard.isDown( "space" ) then
      if shot_limit[shot_limit_index] then
        shootAction()
        shot_limit_index = 1
      else
        shot_limit_index = shot_limit_index + 1
        if shot_limit_index > 6 then
          shot_limit_index = 1
        end  
      end  
    end
    
    removeMeteors()
    
    if #meteors < MAX_METEORS then
      table.insert( meteors, createMeteor( math.random( 2, 4 ) ) )
    end
    
    updateMeteors()
    --moveShots()
    --checkCollisions()
  end
end

-- Draw a coloured rectangle.
function love.draw()
  love.graphics.draw( background_img, 0, 0 )
  
  ---love.graphics.draw( plane.image, plane.x, plane.y )
  plane.draw()
  for i = 1, #meteors do
    meteors[i].draw()
  end
  
  love.graphics.print( "Meteoros Atingidos "..METEORS_HIT, 0, 0 )
  
  for _,shoot in pairs( plane.shots ) do
    love.graphics.draw( shoot_img, shoot.x, shoot.y )
  end  
  
  if GAME_OVER then
    love.graphics.draw( game_over_img, SCREEN_WIDTH / 2 - game_over_img:getWidth()/2 , SCREEN_HEIGHT / 2 - game_over_img:getHeight()/2 )
  end  
end