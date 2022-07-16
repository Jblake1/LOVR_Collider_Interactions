
local plane = {}

function plane.load(enviro)
  local box = enviro:newBoxCollider(vec3(0, -0.11, 0), vec3(7, 0.1, 7))
  box:setKinematic(true)
  box:setUserData('plane')
end

function plane.draw(x1,y1,z1, sx1,sy1,sz1, angle1, ax1,ay1,az1)
    lovr.graphics.setColor(0.3, 0.3, 0.3)
    lovr.graphics.box('fill', x1,y1,z1, sx1,sy1,sz1, angle1, ax1,ay1,az1)
end

return plane