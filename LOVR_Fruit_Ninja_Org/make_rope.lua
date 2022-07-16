
local make_rope = {}

function make_rope.makeRope(origin, destination, thickness, elements, enviro1)
  local length = (destination - origin):length()
  thickness = thickness or length / 100
  elements = elements or 30
  elementSize = length / elements
  local orientation = vec3(destination - origin):normalize()
  local first, last, prev
  for i = 1, elements do
    local position = vec3(origin):lerp(destination, (i - 0.5) / elements)
    local anchor   = vec3(origin):lerp(destination, (i - 1.0) / elements)
    element = enviro1:newBoxCollider(position, vec3(thickness, thickness, elementSize * 0.95))
    element:setRestitution(0.1)
    element:setGravityIgnored(true)
    element:setOrientation(quat(orientation))
    element:setLinearDamping(0.01)
    element:setAngularDamping(0.01)
    element:setMass(0.001)
    if prev then
      local joint = lovr.physics.newBallJoint(prev, element, anchor)
      joint:setResponseTime(10)
      joint:setTightness(1)
    else
      first = element
    end
    prev = element
  end
  last = prev
  return first, last
end 


return make_rope