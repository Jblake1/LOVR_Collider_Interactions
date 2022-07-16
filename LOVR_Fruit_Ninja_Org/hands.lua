local hands = { -- palms that can push and grab objects
  colliders = {nil, nil},     -- physical objects for palms
  touching  = {nil, nil},     -- the collider currently touched by each hand
  holding   = {nil, nil},     -- the collider attached to palm
  solid     = {false, false}, -- hand can either pass through objects or be solid
} -- to be filled with as many hands as there are active controllers

-- make colliders for two hands
function hands.load(enviro)
    for i = 1, 2 do
        hands.colliders[i] = enviro:newBoxCollider(vec3(0,2,0), vec3(0.04, 0.08, 0.08))
        hands.colliders[i]:setLinearDamping(0.2)
        hands.colliders[i]:setAngularDamping(0.3)
        hands.colliders[i]:setMass(0.1)
        hands.colliders[i]:setUserData('hand')
        registerCollisionCallback(hands.colliders[i],
        function(collider, world)
            -- store collider that was last touched by hand
            hands.touching[i] = collider
        end)
    end  
end

function hands.update(time)
-- hand updates - location, orientation, solidify on trigger button, grab on grip button
    for i, hand in pairs(lovr.headset.getHands()) do
        -- align collider with controller by applying force (position) and torque (orientation)
        local rw = mat4(lovr.headset.getPose(hand))   -- real world pose of controllers
        local vr = mat4(hands.colliders[i]:getPose()) -- vr pose of palm colliders
        local angle, ax,ay,az = quat(rw):mul(quat(vr):conjugate()):unpack()
        angle = ((angle + math.pi) % (2 * math.pi) - math.pi) -- for minimal motion wrap to (-pi, +pi) range
        hands.colliders[i]:applyTorque(vec3(ax, ay, az):mul(angle * time * 1))
        hands.colliders[i]:applyForce((vec3(rw:mul(0,0,0)) - vec3(vr:mul(0,0,0))):mul(time * 2000))
        -- solidify when trigger touched
        hands.solid[i] = lovr.headset.isDown(hand, 'trigger')
        hands.colliders[i]:getShapes()[1]:setSensor(not hands.solid[i])
        -- hold/release colliders
        if lovr.headset.isDown(hand, 'grip') and hands.touching[i] and not hands.holding[i] then
        hands.holding[i] = hands.touching[i]
        lovr.physics.newBallJoint(hands.colliders[i], hands.holding[i], vr:mul(0,0,0))
        lovr.physics.newSliderJoint(hands.colliders[i], hands.holding[i], quat(vr):direction())
        end
        if lovr.headset.wasReleased(hand, 'grip') and hands.holding[i] then
        for _,joint in ipairs(hands.colliders[i]:getJoints()) do
            joint:destroy()
        end
        hands.holding[i] = nil
        end
    end
end

function hands.draw(x1,y1,z1, sx1,sy1,sz1, angle1, ax1,ay1,az1)
    lovr.graphics.setColor(0.8, 0.5, 0.9)
    lovr.graphics.box('fill', x1,y1,z1, sx1,sy1,sz1, angle1, ax1,ay1,az1)
end

return hands