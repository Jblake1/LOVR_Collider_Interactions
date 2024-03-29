-- Left thumbstick: move and strafe
-- Right thumbstick: rotate the view horizontally

-- Right grip: switch to snap locomotion mode
-- Left grip: enable flying mode
-- Left trigger: switch orientation to left hand controller (can look around while moving)

local motion = {
  pose = lovr.math.newMat4(), -- Transformation in VR initialized to origin (0,0,0) looking down -Z
  thumbstickDeadzone = 0.4,   -- Smaller thumbstick displacements are ignored (too much noise)
  directionFrom = 'head',     -- Movement can be relative to orientation of head or left controller
  flying = false,
  -- Snap motion parameters
  snapTurnAngle = 2 * math.pi / 12,
  dashDistance = 1.5,
  thumbstickCooldownTime = 0.3,
  thumbstickCooldown = 0,
  -- Smooth motion parameters
  turningSpeed = 2 * math.pi * 1 / 6,
  walkingSpeed = 4,
}

function motion.smooth(time)
  if lovr.headset.isTracked('right') then
    local x, y = lovr.headset.getAxis('right', 'thumbstick')
    -- Smooth horizontal turning
    if math.abs(x) > motion.thumbstickDeadzone then
      motion.pose:rotate(-x * motion.turningSpeed * time, 0, 1, 0)
    end
  end
  if lovr.headset.isTracked('left') then
    local x, y = lovr.headset.getAxis('left', 'thumbstick')
    local direction = quat(lovr.headset.getOrientation(motion.directionFrom)):direction()
    if not motion.flying then
      direction.y = 0
    end
    -- Smooth strafe movement
    if math.abs(x) > motion.thumbstickDeadzone then
      local strafeVector = quat(-math.pi / 2, 0,1,0):mul(vec3(direction))
      motion.pose:translate(strafeVector * x * motion.walkingSpeed * time)
    end
    -- Smooth Forward/backward movement
    if math.abs(y) > motion.thumbstickDeadzone then
      motion.pose:translate(direction * y * motion.walkingSpeed * time)
    end
  end
end

function motion.snap(time)
  -- Snap horizontal turning
  if lovr.headset.isTracked('right') then
    local x, y = lovr.headset.getAxis('right', 'thumbstick')
    if math.abs(x) > motion.thumbstickDeadzone and motion.thumbstickCooldown < 0 then
      local angle = -x / math.abs(x) * motion.snapTurnAngle
      motion.pose:rotate(angle, 0, 1, 0)
      motion.thumbstickCooldown = motion.thumbstickCooldownTime
    end
  end
  -- Dashing forward/backward
  if lovr.headset.isTracked('left') then
    local x, y = lovr.headset.getAxis('left', 'thumbstick')
    if math.abs(y) > motion.thumbstickDeadzone and motion.thumbstickCooldown < 0 then
      local moveVector = quat(lovr.headset.getOrientation('head')):direction()
      if not motion.flying then
        moveVector.y = 0
      end
      moveVector:mul(y / math.abs(y) * motion.dashDistance)
      motion.pose:translate(moveVector)
      motion.thumbstickCooldown = motion.thumbstickCooldownTime
    end
  end
  motion.thumbstickCooldown = motion.thumbstickCooldown - time
end
 

return motion




--[[ function lovr.draw()
  lovr.graphics.setBackgroundColor(0.1, 0.1, 0.1)
  lovr.graphics.transform(mat4(motion.pose):invert())
  -- Render hands
  lovr.graphics.setColor(1,1,1)
  local radius = 0.05
  for _, hand in ipairs(lovr.headset.getHands()) do
    -- Whenever pose of hand or head is used, need to account for VR movement
    local poseRW = mat4(lovr.headset.getPose(hand))
    local poseVR = mat4(motion.pose):mul(poseRW)
    poseVR:scale(radius)
    lovr.graphics.sphere(poseVR)
  end

 ]]