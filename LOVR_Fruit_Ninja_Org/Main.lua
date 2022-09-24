
local sword = require('sword')
local plane = require('plane')
local hands = require('hands')
local box = require('box')
local wball = require('wrecking_ball')
--local motion = require('locamotion')

local world
local collisionCallbacks = {}
local framerate = 1 / 72 -- fixed framerate is recommended for physics updates


function lovr.load()
  world = lovr.physics.newWorld(0, -2, 0, false) -- low gravity and no collider sleeping
  -- load plane box
  plane.load(world)
  -- load sword box
  sword.load(world)
  -- load hands
  hands.load(world)
  -- load box
  box.load(world)
  --wrecking ball
  wball.load(world)

  --moving ball 
  --local ballPosition = vec3(-1, 2, -1)
  --local ball = world:newSphereCollider(ballPosition, 0.2)
  --ball:setUserData(colliderUserData)

    lovr.graphics.setBackgroundColor(0.1, 0.1, 0.1)
end


function lovr.keypressed(key)
  if key == 'space' then 
    Hand_grabbing = true
  end
end

function lovr.keyreleased(key)
  if key == 'space' then 
    Hand_grabbing = false
  end
end


function lovr.update(dt)
  -- override collision resolver to notify all colliders that have registered their callbacks
  world:update(framerate, function(world)
    world:computeOverlaps()
    for shapeA, shapeB in world:overlaps() do
      local areColliding = world:collide(shapeA, shapeB)
      if areColliding then
        cbA = collisionCallbacks[shapeA]
        if cbA then cbA(shapeB:getCollider(), world) end
        cbB = collisionCallbacks[shapeB]
        if cbB then cbB(shapeA:getCollider(), world) end
      end
    end
  end)

  hands.update(dt)
  --sword.update(dt)

  -- motion update (need to update hand colliders)!!!
 --[[  motion.directionFrom = lovr.headset.isDown('left', 'trigger') and 'left' or 'head'
  if lovr.headset.isDown('left', 'grip') then
    motion.flying = true
  elseif lovr.headset.wasReleased('left', 'grip') then
    motion.flying = false
    local height = vec3(motion.pose).y
    motion.pose:translate(0, -height, 0)
  end
  if lovr.headset.isDown('right', 'grip') then
    motion.snap(dt)
  else
    motion.smooth(dt)
  end ]]
end


function lovr.draw()
  --local sword = require('sword')
  --Create Coordinate lines
  local coordinates = require('coordinates')
  local Height = 0

  coordinates.draw(Height)

  --lovr.graphics.transform(mat4(motion.pose):invert())

  for i, collider in ipairs(world:getColliders()) do
    local shape = collider:getShapes()[1]
    local shapeType = shape:getType()
    local x,y,z, angle, ax,ay,az = collider:getPose()
    if shapeType == 'box' then
      local sx, sy, sz = shape:getDimensions()
      local colliderUserData = collider:getUserData()
      if colliderUserData == 'plane' then
        plane.draw(x,y,z, sx,sy,sz, angle, ax,ay,az)
      elseif colliderUserData == 'hand' then
        --need to insert motion impact on hand colliders through hand class
          hands.draw(x,y,z, sx,sy,sz, angle, ax,ay,az)
      elseif colliderUserData == 'sword' then
        sword.draw(x,y,z, sx,sy,sz, angle, ax,ay,az)
      else
        box.draw(x,y,z, sx,sy,sz, angle, ax,ay,az)
      end
    elseif shapeType == 'sphere' then
      lovr.graphics.setColor(0.8, 0, 0)
      lovr.graphics.sphere(x,y,z, shape:getRadius())
    end
  end
end


function registerCollisionCallback(collider, callback)
  collisionCallbacks = collisionCallbacks or {}
  for _, shape in ipairs(collider:getShapes()) do
    collisionCallbacks[shape] = callback
  end
end 



