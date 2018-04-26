SCREEN_WIDTH = 320
SCREEN_HEIGHT = 480
MAX_METEORS = 22
METEORS_HIT = 0
shot_limit_index = 10

function newPlayer()
  local x, y = SCREEN_WIDTH / 2 - 32, SCREEN_HEIGHT - 64
  local width, height = 40, 40
  local img = plane_img
  return{
    shots = {},
    changeImg = function(newImg)
     img = newImg
    end,  
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

function destroyPlane()
  plane_destruction_sound:play()
  plane_image = love.graphics.newImage( "imagens/explosion_plane.png" )
  player.changeImg( plane_image )  
  player.width = 67 
  player.height = 77
end  


function shootAction( player, speed )
  shoot_sound:stop()
  shoot_sound:play()
  local x = player.getX() + player.getWidth() / 2 + 2
  local y = player.getY()
  local width, height = 16, 16
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
    update = coroutine.wrap( function()
      while(1) do
        if y > 0 then
          y = y - 3
        end
        wait( speed / 10000  )
      end
    end),
    
    draw = function()
      love.graphics.draw( shoot_img, x, y )
    end,  
    
    isActive = function()
      return now > isActiveAfter
    end
  }  
end

function updateShots( player )
  for i = #player.shots,1,-1 do
    if player.shots[i].isActive() then
      player.shots[i].update()
    end
    if player.shots[i].getY() < 0 then
      table.remove( player.shots, i )
    end 
  end  
end

function createMeteor( speed )
  local x, y = math.random( -20, SCREEN_WIDTH + 20 ), -70
  local width, height = 30, 25
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
    update = coroutine.wrap( function() 
      while(1) do
        y = y + 2
        x = x + horizontal_movement
        wait( speed / 1000000 )
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

function hasCollision( x1, y1, l1, a1, x2, y2, l2, a2)
  return x2 < x1 + l1 and
         x1 < x2 + l2 and
         y1 < y2 + a2 and
         y2 < y1 + a1
end

function checkCollisionPlaneMeteor()
  for k,meteor in pairs(meteors) do
    if hasCollision( meteor.getX(), meteor.getY(), meteor.getWidth(), meteor.getHeight(), 
                     player.getX(), player.getY(), player.getWidth(), player.getHeight() ) then
      changeMusic()               
      destroyPlane() 
      GAME_OVER = true
    end
  end
end

function checkCollisionShotMeteor()
  for i = #player.shots, 1, -1 do
    for j = #meteors, 1, -1 do
      if hasCollision( player.shots[i].getX(), player.shots[i].getY(),
                      player.shots[i].getWidth(), player.shots[i].getHeight(),
                      meteors[j].getX(), meteors[j].getY(),
                      meteors[j].getWidth(), meteors[j].getHeight() ) then
        METEORS_HIT = METEORS_HIT + 1
        meteor_destruction_sound:stop()
        meteor_destruction_sound:play()
        createMeteorExplosionRoutine( meteors[j].getX()-35, meteors[j].getY() )
        table.remove( player.shots, i )
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

function printBackground()
    love.graphics.draw( background_img, 0, backgroundPosY ) 
    love.graphics.draw( background_img, 0, backgroundPosY - 480 ) 
    
    if not GAME_OVER then
      backgroundPosY = backgroundPosY + 1 
    end
    
    if backgroundPosY >= 480 then
      backgroundPosY = 0 
    end
end

function createMeteorExplosionRoutine( x , y )
  co = coroutine.create(function ( x, y )
    local j = 1
    for i = 1, 3*#meteor_explosion_imgs do
      love.graphics.draw( meteor_explosion_imgs[j], x, y+i*3 )
      if i % 3 == 1 then
        j = j + 1
      end
      coroutine.yield()
    end
  end)
  table.insert( meteorExplosions, {co,x,y} )
end


function drawMeteorExplosions()
  for i = #meteorExplosions, 1, -1 do
    coroutine.resume( meteorExplosions[i][1] , meteorExplosions[i][2], meteorExplosions[i][3] )
    if coroutine.status( meteorExplosions[i][1] ) == "dead" then
      table.remove( meteorExplosions, i )
    end 
  end
end
       
-- Increase the size of the rectangle every frame.
function love.update(dt)
  now = os.clock()
  if not GAME_OVER then
    if love.keyboard.isDown( "escape" ) then
      love.event.quit()
    end
    if love.keyboard.isDown( "w") then
      player.movePlane("w")
    end
    if love.keyboard.isDown( "s") then
      player.movePlane("s")
    end
    if love.keyboard.isDown( "a") then
      player.movePlane("a")
    end
    if love.keyboard.isDown( "d") then
      player.movePlane("d")
    end
    if love.keyboard.isDown( "space" ) then
      if shot_limit_index == 10 then
        table.insert( player.shots, shootAction( player, 3 ) ) 
        shot_limit_index = 1
      else
        shot_limit_index = shot_limit_index + 1
        if shot_limit_index > 10 then
          shot_limit_index = 1
        end  
      end 
    end
    
    removeMeteors()
    
    if #meteors < MAX_METEORS then
      table.insert( meteors, createMeteor( math.random( 4,8 ) ) )
    end
    
    updateMeteors()
    updateShots( player )
    checkCollisions()
  end
end

-- Draw a coloured rectangle.
function love.draw()
  printBackground()
  player.draw()
  for i = 1, #meteors do
    meteors[i].draw()
  end
  for i = 1, #player.shots do
    player.shots[i].draw()
  end
  drawMeteorExplosions()
  love.graphics.print( "Meteoros Atingidos "..METEORS_HIT, 0, 0 )
  
  if GAME_OVER then
    love.graphics.draw( game_over_img, SCREEN_WIDTH / 2 - game_over_img:getWidth() / 2, 
                        SCREEN_HEIGHT / 2 - game_over_img:getHeight() / 2 )
  end  
end 
 
-- Load some default values for our rectangle.
function love.load() 
  love.window.setMode( SCREEN_WIDTH , SCREEN_HEIGHT, {resizable = false} )
  love.window.setTitle( "Miniprojeto Love" )
  math.randomseed( os.time() )
  
  environment_music = love.audio.newSource( "audios/environment.wav", "static" )
  environment_music:setLooping(true)
  environment_music:play()
  game_over_music = love.audio.newSource( "audios/game_over.wav", "static" )
  plane_destruction_sound = love.audio.newSource( "audios/plane_destruction.wav", "static" )
  meteor_destruction_sound = love.audio.newSource( "audios/meteor_destruction.wav", "static" )
  shoot_sound = love.audio.newSource( "audios/shoot.wav", "static" )
  
  plane_img = love.graphics.newImage( "imagens/plane.png" )
  background_img = love.graphics.newImage( "imagens/background.png" )
  background_img2 = love.graphics.newImage( "imagens/background.png" )
  game_over_img = love.graphics.newImage( "imagens/gameover.png" )
  
  meteor_imgs = {
    love.graphics.newImage( "imagens/meteor1.png" ),
    love.graphics.newImage( "imagens/meteor2.png" ), 
    love.graphics.newImage( "imagens/meteor3.png" ),
    love.graphics.newImage( "imagens/meteor4.png" )
  }
  meteor_explosion_imgs = {
    love.graphics.newImage( "imagens/RedExplosion/1_0.png" ),
    love.graphics.newImage( "imagens/RedExplosion/1_1.png" ),
    love.graphics.newImage( "imagens/RedExplosion/1_2.png" ),
    love.graphics.newImage( "imagens/RedExplosion/1_3.png" ),
    love.graphics.newImage( "imagens/RedExplosion/1_4.png" ),
    love.graphics.newImage( "imagens/RedExplosion/1_5.png" ),
    love.graphics.newImage( "imagens/RedExplosion/1_6.png" ),
    love.graphics.newImage( "imagens/RedExplosion/1_7.png" ),
    love.graphics.newImage( "imagens/RedExplosion/1_8.png" ),
    love.graphics.newImage( "imagens/RedExplosion/1_9.png" ),
    love.graphics.newImage( "imagens/RedExplosion/1_10.png" ),
    love.graphics.newImage( "imagens/RedExplosion/1_11.png" ),
    love.graphics.newImage( "imagens/RedExplosion/1_12.png" ),
    love.graphics.newImage( "imagens/RedExplosion/1_13.png" ),
    love.graphics.newImage( "imagens/RedExplosion/1_14.png" ),
    love.graphics.newImage( "imagens/RedExplosion/1_15.png" ),
    love.graphics.newImage( "imagens/RedExplosion/1_16.png" )
  } 
  shoot_img = love.graphics.newImage( "imagens/shoot.png" )
  
  player = newPlayer()
  meteors = {}
  meteorExplosions = {}
  backgroundPosY = 0
end