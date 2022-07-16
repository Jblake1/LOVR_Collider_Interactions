local box = {}

function box.load(enviro)
-- load brick wall 
    local x = 0.3
    local even = true
    for y = 1, 0.1, -0.1 do
      for z = -0.5, -1.5, -0.2 do
        enviro:newBoxCollider(x, y, even and z or z - 0.1, 0.08, 0.1, 0.2)
      end
      even = not even
    end
end

function box.draw(x1,y1,z1, sx1,sy1,sz1, angle1, ax1,ay1,az1)
    lovr.graphics.setColor(0.2, 0.5, 0.6)
    lovr.graphics.box('fill', x1,y1,z1, sx1,sy1,sz1, angle1, ax1,ay1,az1)
end


return box