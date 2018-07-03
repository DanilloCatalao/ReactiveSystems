
p = love.physics
g = love.graphics
k = love.keyboard
Camera = require "camera"
Timer = require "timer"
vector = require "vector"
mqtt = require("mqtt_library")
camera = Camera.new(297,108,1,0)
camera:zoom(0.56)
playerOnePoints = 0
playerTwoPoints = 0
currentPlayer = 1
pointsLock = false
waitingPlayer = true


function mqttcallback(topic, message)
  if topic == "throw" then
    if not waitingPlayer and not objects.ball.motion then
      if currentPlayer == tonumber(message) then
        local power = 110
        applyForceToBall(throwVector.x*power,throwVector.y*power)
        objects.ball.motion = true
        Timer.after(5,function() turnRoutine() end)
        waitingPlayer = false
      end
    end
  else --turn
    if message == "1" then
      if currentPlayer == 1 then
        waitingPlayer = false
      end
    else --2
      if currentPlayer == 2 then
        waitingPlayer = false
      end
    end
  end
end

function createObjects()
  objects.ground = {}
  objects.ground.body = p.newBody(world, 300000/6, 625)
  objects.ground.shape = p.newRectangleShape(300000, 50)
  objects.ground.fixture = p.newFixture(objects.ground.body, objects.ground.shape)

  objects.ball = {}
  objects.ball.motion = false
  objects.ball.body = p.newBody(world, 700, 355, "dynamic")
  objects.ball.shape = p.newCircleShape(20)
  objects.ball.fixture = p.newFixture(objects.ball.body, objects.ball.shape, 1)
  objects.ball.fixture:setRestitution(0.50)
  --camera:lookAt(objects.ball.body:getX(), objects.ball.body:getY())

  objects.block1 = {}
  objects.block1.body = p.newBody(world, -200, 300)
  objects.block1.shape = p.newRectangleShape( 20, 600)
  objects.block1.fixture = p.newFixture(objects.block1.body, objects.block1.shape, 5)

  objects.block2 = {}
  objects.block2.body = p.newBody(world, -102.5, -10)
  objects.block2.shape = p.newRectangleShape( 215, 20)
  objects.block2.fixture = p.newFixture(objects.block2.body, objects.block2.shape, 5)

  objects.block3 = {}
  objects.block3.body = p.newBody(world, 0, 0)
  objects.block3.shape = p.newRectangleShape( 25, 200)
  objects.block3.fixture = p.newFixture(objects.block3.body, objects.block3.shape, 5)

  objects.block4 = {}
  objects.block4.body = p.newBody(world, 0, 0)
  objects.block4.shape = p.newPolygonShape(-200,100,-200,115,-65,-10,-80,-10)
  objects.block4.fixture = p.newFixture(objects.block4.body, objects.block4.shape, 5)

  objects.block5 = {}
  objects.block5.body = p.newBody(world, 0, 0)
  objects.block5.shape = p.newEdgeShape(12.5,50,50,50)
  objects.block5.fixture = p.newFixture(objects.block5.body, objects.block5.shape, 5)

  objects.block6 = {}
  objects.block6.body = p.newBody(world, 0, 0)
  objects.block6.shape = p.newEdgeShape(12.5,65,50,50)
  objects.block6.fixture = p.newFixture(objects.block6.body, objects.block6.shape, 5)

  objects.block7 = {}
  objects.block7.body = p.newBody(world, 700, 400)
  objects.block7.shape = p.newRectangleShape(100, 50)
  objects.block7.fixture = p.newFixture(objects.block7.body, objects.block7.shape, 2)

  objects.hoop1 = {}
  objects.hoop1.body = p.newBody(world, 50, 50)
  objects.hoop1.shape = p.newCircleShape(5)
  objects.hoop1.fixture = p.newFixture(objects.hoop1.body, objects.hoop1.shape, 5)

  objects.net11 = {}
  objects.net11.body = p.newBody(world,50,69,"dynamic")
  objects.net11.shape = p.newRectangleShape(4,28)
  objects.net11.fixture = p.newFixture(objects.net11.body, objects.net11.shape)

  objects.net12 = {}
  objects.net12.body = p.newBody(world,50,97,"dynamic")
  objects.net12.shape = p.newRectangleShape(4,28)
  objects.net12.fixture = p.newFixture(objects.net12.body, objects.net12.shape)

  objects.net13 = {}
  objects.net13.body = p.newBody(world,50,125,"dynamic")
  objects.net13.shape = p.newRectangleShape(4,28)
  objects.net13.fixture = p.newFixture(objects.net13.body, objects.net13.shape)

  objects.hoop2 = {}
  objects.hoop2.body = p.newBody(world, 140, 50)
  objects.hoop2.shape = p.newCircleShape(5)
  objects.hoop2.fixture = p.newFixture(objects.hoop2.body, objects.hoop2.shape, 5)

  objects.net21 = {}
  objects.net21.body = p.newBody(world,140,69,"dynamic")
  objects.net21.shape = p.newRectangleShape(4,28)
  objects.net21.fixture = p.newFixture(objects.net21.body, objects.net21.shape)

  objects.net22 = {}
  objects.net22.body = p.newBody(world,140,97,"dynamic")
  objects.net22.shape = p.newRectangleShape(4,28)
  objects.net22.fixture = p.newFixture(objects.net22.body, objects.net22.shape)

  objects.net23 = {}
  objects.net23.body = p.newBody(world,140,125,"dynamic")
  objects.net23.shape = p.newRectangleShape(4,28)
  objects.net23.fixture = p.newFixture(objects.net23.body, objects.net23.shape)

  jointNetHoop1 = love.physics.newRevoluteJoint( objects.net11.body, objects.hoop1.body, 50, 50, true )
  jointNetNet11 = love.physics.newRevoluteJoint( objects.net11.body, objects.net12.body, 50, 84, true )
  jointNetNet12 = love.physics.newRevoluteJoint( objects.net12.body, objects.net13.body, 50, 112, true )

  jointNetHoop2 = love.physics.newRevoluteJoint( objects.net21.body, objects.hoop2.body, 140, 50, true )
  jointNetNet21 = love.physics.newRevoluteJoint( objects.net21.body, objects.net22.body, 140, 84, true )
  jointNetNet22 = love.physics.newRevoluteJoint( objects.net22.body, objects.net23.body, 140, 112, true )

  jointNets1 = love.physics.newDistanceJoint( objects.net11.body, objects.net21.body, objects.net11.body:getX(),objects.net11.body:getY(),
                              objects.net21.body:getX(),objects.net21.body:getY(), false )
  jointNets1:setLength(60)
  jointNets1:setFrequency(2)
  jointNets1:setDampingRatio( 0.4 )

  jointNets2 = love.physics.newDistanceJoint( objects.net12.body, objects.net22.body, objects.net12.body:getX(),objects.net12.body:getY(),
                              objects.net22.body:getX(),objects.net22.body:getY(), false )
  jointNets2:setLength(45)
  jointNets2:setFrequency(1/10)
  jointNets2:setDampingRatio( 0.4 )

  jointNets3 = love.physics.newDistanceJoint( objects.net13.body, objects.net23.body, objects.net13.body:getX(),objects.net13.body:getY(),
                              objects.net23.body:getX(),objects.net23.body:getY(), false )
  jointNets3:setLength(30)
  jointNets3:setFrequency(1)
  jointNets3:setDampingRatio( 0.4 )
end

function love.load()

  mqtt_client = mqtt.client.create("test.mosquitto.org", 1883, mqttcallback)
  mqtt_client:connect("1320966")
  mqtt_client:subscribe({"throw","turn"})

  Timer.new()


  p.setMeter(100)
  world = p.newWorld(0, 9.81*63, true)
  objects = {}

  createObjects()
  ballImg = g.newImage("ball.png")

  throwVector = vector.fromPolar(math.pi,1)

  g.setBackgroundColor(0.41, 0.53, 0.97) --set the background color to a nice blue
  love.window.setMode(700, 600)

  font = love.graphics.newFont("joystix monospace.ttf", 12)
  g.setFont(font)

end


function love.update(dt)
  world:update(dt)

  mqtt_client:handler()

  if k.isDown("right") then
    objects.ball.body:applyForce(400, 0)
  elseif k.isDown("left") then
    objects.ball.body:applyForce(-400, 0)
  elseif k.isDown("up") then
    objects.ball.body:applyForce(0, -400)
  elseif k.isDown("down") then
    objects.ball.body:applyForce(0, 400)
  elseif k.isDown("z") then
    --camera:zoom(1.2)
    waitingPlayer = false
  elseif k.isDown("o") then
    camera:zoom(0.8)
  elseif k.isDown("w") then
    camera:move(0,-9)
  elseif k.isDown("s") then
    camera:move(0,9)
  elseif k.isDown("a") then
    camera:move(-9,0)
  elseif k.isDown("d") then
    camera:move(9,0)
  elseif k.isDown("q") then
    camera:rotate(-0.2)
  elseif k.isDown("e") then
    camera:rotate(0.2)
  elseif k.isDown("r") then
    objects.ball.body:setLinearVelocity(0, 0)
    objects.ball.body:setAngularVelocity(0)
    objects.ball.body:setPosition(700, 355)
  end

  if objects.ball.motion == false then
    if not waitingPlayer then
      updateThrowVector()
    end
  else
    updateScore()
  end
  Timer.update(dt)



end

function updateThrowVector()
  throwVector:rotateInplace(0.03)
end

function updateScore()
  local bx,by,hx1,hx2,hy =  objects.ball.body:getX(),objects.ball.body:getY(),objects.hoop1.body:getX(),objects.hoop2.body:getX(),objects.hoop1.body:getY()
  if  bx >=  hx1 and bx <= hx2  and
      by >= hy and by <= hy+7 and pointsLock == false then
      if(currentPlayer == 1) then playerOnePoints = playerOnePoints+1
      else
        playerTwoPoints = playerTwoPoints+1
      end
      pointsLock = true
  end
end

function  turnRoutine()
  objects.ball.body:setLinearVelocity(0, 0)
  objects.ball.body:setAngularVelocity(0)
  objects.ball.body:setPosition(700, 355)
  objects.ball.motion = false
  throwVector = vector.fromPolar(math.pi,1)
  pointsLock = false
  waitingPlayer = true
  if currentPlayer == 1 then
    currentPlayer = 2
  else
    currentPlayer = 1
  end
end


function applyForceToBall(x,y)
  objects.ball.body:applyLinearImpulse(x,y,objects.ball.body:getX(),objects.ball.body:getY()-1)
end

function love.keypressed(key)
   if key == "f" then
      --applyForceToBall(-47,-88)
      local power = 110
      applyForceToBall(throwVector.x*power,throwVector.y*power)
      objects.ball.motion = true
      Timer.after(5,function() turnRoutine() end)
   end
end

function drawHoop()
  x,y = objects.net11.body:getPosition()
  i,j = objects.hoop2.body:getPosition()
  g.line(x,y,i,j)

  x,y = objects.net21.body:getPosition()
  i,j = objects.hoop1.body:getPosition()
  g.line(x,y,i,j)

  x,y = objects.net11.body:getPosition()
  i,j = objects.net22.body:getPosition()
  g.line(x,y,i,j)

  x,y = objects.net12.body:getPosition()
  i,j = objects.net23.body:getPosition()
  g.line(x,y,i,j)

  x,y = objects.net12.body:getPosition()
  i,j = objects.net21.body:getPosition()
  g.line(x,y,i,j)

  x,y = objects.net12.body:getPosition()
  i,j = objects.net21.body:getPosition()
  g.line(x,y,i,j)

  x,y = objects.net13.body:getPosition()
  i,j = objects.net22.body:getPosition()
  g.line(x,y,i,j)

  _,_,_,_,_,_,x,y = objects.net13.body:getWorldPoints(objects.net13.shape:getPoints())
  i,j = objects.net23.body:getPosition()
  g.line(x,y,i,j)
  _,_,_,_,_,_,x,y = objects.net23.body:getWorldPoints(objects.net23.shape:getPoints())
  i,j = objects.net13.body:getPosition()
  g.line(x,y,i,j)

  g.setColor(0.76, 0.18, 0.05)
  g.line(objects.hoop1.body:getX(),objects.hoop1.body:getY(),objects.hoop2.body:getX(),objects.hoop2.body:getY())
end

function love.draw()
  camera:attach()

  g.setColor(0,0,0)
  drawHoop()
  for _, body in pairs(world:getBodies()) do
    for _, fixture in pairs(body:getFixtures()) do
      local shape = fixture:getShape()
      if shape:typeOf("CircleShape") then
        g.setColor(0.76, 0.18, 0.05)
        local cx, cy = body:getWorldPoints(shape:getPoint())
        g.circle("fill", cx, cy, shape:getRadius())
      elseif shape:typeOf("PolygonShape") then
        g.setColor(0.20, 0.20, 0.20)
        g.polygon("fill", body:getWorldPoints(shape:getPoints()))
      else
        g.line(body:getWorldPoints(shape:getPoints()))
      end
    end
  end

  g.setColor(1, 0, 0, 100)
  local cx, cy = objects.ball.body:getWorldPoints(objects.ball.shape:getPoint())
  g.draw(ballImg,cx,cy,objects.ball.body:getAngle(),0.07,0.07,ballImg:getWidth()/2,ballImg:getHeight()/2)

  g.setColor(255, 255, 255, 100)
  g.print("Player 1: "..playerOnePoints,-300,-420,0,3.0,3.0)
  g.print("Player 2: "..playerTwoPoints,555,-420,0,3.0,3.0)

  if not objects.ball.motion then
    g.line(cx,cy,cx+throwVector.x*40,cy+throwVector.y*40)
  end

  if not objects.ball.motion and waitingPlayer then
    drawPlayerWaitingScreen(currentPlayer)
  end

  camera:detach()
end

function drawPlayerWaitingScreen(player)
  g.print("Jogador ".. player.."\nPressione o botão 2\npara continuar",0,150,0,3,3)
end
