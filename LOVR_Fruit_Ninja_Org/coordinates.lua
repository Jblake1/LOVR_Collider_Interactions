
local coordinates = {}

function coordinates.draw(h)
  lovr.graphics.setColor(1, 0, 0) -- red
  lovr.graphics.line(0,h,0,1,h,0)
  lovr.graphics.setColor(0.0, 1, 0) -- green
  lovr.graphics.line(0,h,0,0,2,0)
  lovr.graphics.setColor(0, 0, 1) -- blue 
  lovr.graphics.line(0,h,0,0,h,1)
end

return coordinates