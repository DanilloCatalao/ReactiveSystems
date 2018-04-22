SCREEN_WIDTH = 320
SCREEN_HEIGHT = 480
MAX_METEORS = 18
METEORS_HIT = 0
plane = {
  src = "imagens/plane.png",
  width = 55,
  height = 55,
  x = SCREEN_WIDTH / 2 - 32,
  y = SCREEN_HEIGHT - 64,
  shots = {} 
}

function movePlane()
  if love.keyboard.isDown("w") then
      plane.y = plane.y - 3
  end
  if love.keyboard.isDown("s") then
    plane.y = plane.y + 3
  end  
  if love.keyboard.isDown("a") then
    plane.x = plane.x - 3
  end  
  if love.keyboard.isDown("d") then
    plane.x = plane.x + 3
  end 
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

function checkCollisionPlaneMeteor()
  for k,meteor in pairs(meteors) do
    if hasCollision( meteor.x, meteor.y, meteor.width, meteor.height,
                     plane.x, plane.y, plane.width, plane.height ) then
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
    img = meteor_imgs[ math.random( 4 ) ] ,
    x = math.random( SCREEN_WIDTH ),
    y = -70,
    width = 35,
    height = 35,
    weight = math.random( 2, 4 ),
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

--function love.keypressed(key)
  --if key == "escape" then
   -- love.event.quit()
  --elseif key == "space" then
  --  shootAction()
 -- end 
--end
-- Load some default values for our rectangle.
function love.load()
  love.window.setMode( SCREEN_WIDTH , SCREEN_HEIGHT, {resizable = false} )
  love.window.setTitle( "14bis vs Meteoros" )
  
  math.randomseed( os.time() )
  
  plane.image = love.graphics.newImage( plane.src )
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
  
end

shot_limit = {false,false,false,false,false,true}
shot_limit_index = 0
-- Increase the size of the rectangle every frame.
function love.update(dt)
  if not GAME_OVER then
    if love.keyboard.isDown( "escape" ) then
      love.event.quit()
    end
    if love.keyboard.isDown( "w", "a", "s", "d" ) then
      movePlane()
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
      createMeteor()
    end
    
    moveMeteors()
    moveShots()
    checkCollisions()
  end
end

-- Draw a coloured rectangle.
function love.draw()
  love.graphics.draw( background_img, 0, 0 )
  love.graphics.draw( plane.image, plane.x, plane.y )
  
  love.graphics.print( "Meteoros Atingidos "..METEORS_HIT, 0 , 0 )
  
  for k,meteor in pairs(meteors) do
    love.graphics.draw( meteor.img, meteor.x, meteor.y )
  end
  
  for _,shoot in pairs( plane.shots ) do
    love.graphics.draw( shoot_img, shoot.x, shoot.y )
  end  
  
  if GAME_OVER then
    love.graphics.draw( game_over_img, SCREEN_WIDTH / 2 - game_over_img:getWidth()/2 , SCREEN_HEIGHT / 2 - game_over_img:getHeight()/2 )
  end  
end