
local sword = {}

function sword.load(enviro)
    local swordPosition = vec3(1,3,0)
    local swordbox = enviro:newBoxCollider(swordPosition, vec3(0.04, 0.08, 1))
    swordbox:setUserData("sword")
end 


function sword.draw(x1,y1,z1, sx1,sy1,sz1, angle1, ax1,ay1,az1)
    lovr.graphics.setColor(0.1, 0.5, 0.1)
    lovr.graphics.box('fill', x1,y1,z1, sx1,sy1,sz1, angle1, ax1,ay1,az1)
end

return sword