--[[ Hand interaction with physics world: use trigger to solidify hand, grip to grab objects

To manipulate objects in world, we create box collider (palm) for each hand controller. This box
is updated to track location of controller.

The naive approach would be to set exact location and orientation of physical collider with values
from hand controller. This results in lousy and unconvincing collisions with other objects, as
physics engine doesn't know the speed of hand colliders at the moment of collision.

An improvement is to set linear and angular speed of kinematic hand colliders so that they
approach the target (actual location/orientation of hand controller). This works excellent for one
controller. When you try to squeeze an object between two hands, physics break. This is because
kinematic hand controllers are never affected by physics engine and unrealistic material
penetration cannot be resolved.

The approach taken here is to have hand controllers behave as normal dynamic colliders that can be
affected by other collisions. To track hand controllers, we apply force and torque on collider
objects that's proportional to distance from correct position.

This means hand colliders won't have 1:1 mapping with actual hand controllers, they will actually
'bend' under large force. Also the colliders can actually become stuck behind another object. This
is sometimes frustrating to use, so in this example hand colliders can ghost through objects or
become solid using trigger button.

Grabbing objects is done by creating two joints between hand collider and object to hold them
together. This enables pulling, stacking and throwing.                                      --]]


sword = require('sword')
plane = require('plane')
hands = require('hands')
box = require('box')
wball = require('wrecking_ball')

local collisionCallbacks = {}

local framerate = 1 / 72 -- fixed framerate is recommended for physics updates

function lovr.load()
  --local sword = require('sword')
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
  --ball:setUserData(colliderColor)
  
    lovr.graphics.setBackgroundColor(0.1, 0.1, 0.1)
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
  hands.touching = {nil, nil} -- to be set again in collision resolver

end



function lovr.draw()
  --local sword = require('sword')
  --Create Coordinate lines
  local coordinates = require('coordinates')
  local Height = 0

  coordinates.draw(Height)

  for i, collider in ipairs(world:getColliders()) do
  -- original coloring system
  --local shade = (i - 10) / #world:getColliders()
  -- lovr.graphics.setColor(shade, shade, shade)
    local shape = collider:getShapes()[1]
    local shapeType = shape:getType()
    local x,y,z, angle, ax,ay,az = collider:getPose()
    if shapeType == 'box' then
      local sx, sy, sz = shape:getDimensions()
      local colliderColor = collider:getUserData()
      if colliderColor == 'plane' then
        plane.draw(x,y,z, sx,sy,sz, angle, ax,ay,az)
      elseif colliderColor == 'hand' then
        hands.draw(x,y,z, sx,sy,sz, angle, ax,ay,az)
      elseif colliderColor == 'sword' then
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
  
end -- to be called with arguments callback(otherCollider, world) from update function


