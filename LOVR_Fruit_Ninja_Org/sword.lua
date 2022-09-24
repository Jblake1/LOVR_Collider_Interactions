
local sword = {}

function sword.load(enviro)
    local swordPosition = vec3(1,3,0)
    local swordDimensions = vec3(0.02, 0.8, 0.04)
    --local width, height, depth = swordDimensions:unpack()
    swordbox = enviro:newBoxCollider(swordPosition, swordDimensions)
    swordShape = lovr.physics.newBoxShape(swordDimensions)
    swordbox:addShape(swordShape)
    swordbox:setUserData("sword")
end 

function sword.update(dt)
    --local sword_angle, sword_ax, sword_ay, sword_az = sword:getOrientation()
    --local sword_x, sword_y, sword_z = sword:getPosition()
end


function sword.draw(x1,y1,z1, sx1,sy1,sz1, angle1, ax1,ay1,az1)
    lovr.graphics.setColor(0.1, 0.5, 0.1)
    lovr.graphics.box('fill', x1,y1,z1, sx1,sy1,sz1, angle1, ax1,ay1,az1)
end

function sword.setPose(x, y, z, angle, ax, ay, az)
    swordbox:setPose(x, y, z, angle, ax, ay, az)
end

function sword.getLength(collider)
    local shapes = collider:getShapes()
    for _,shape in pairs(shapes) do
        local width, height, depth  = shape:getDimensions()
        return height
    end
end

return sword