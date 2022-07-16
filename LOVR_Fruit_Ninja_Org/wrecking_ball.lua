
local wball = {}
local makeRope = require('make_rope')

function wball.load(enviro)
   -- hangar
  local hangerPosition = vec3(0, 2, -1)
  local hanger = enviro:newBoxCollider(hangerPosition, vec3(0.3, 0.1, 0.3))
  hanger:setKinematic(true)
  --ball
  local ballPosition = vec3(0,0.5, -1)
  local ball2 = enviro:newSphereCollider(ballPosition, 0.2)
  ball2:applyForce(3,4,0)
  --rope
  local firstEnd, lastEnd = makeRope.makeRope(
      hangerPosition + vec3(0, -0.1, 0),
      ballPosition   + vec3(0,  0.3, 0),
      0.02, 10,enviro)
    lovr.physics.newDistanceJoint(hanger, firstEnd, hangerPosition, vec3(firstEnd:getPosition()))
    lovr.physics.newDistanceJoint(ball2, lastEnd, ballPosition, vec3(lastEnd:getPosition()))
end


return wball