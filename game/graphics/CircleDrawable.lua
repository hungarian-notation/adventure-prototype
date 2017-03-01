local Vector = require 'eonz.Vector'

return function(radius, rgba)
  return function(e)
    love.graphics.setColor(rgba or e.color or {255, 255, 255})
    love.graphics.circle('fill', 0, 0, radius or e.radius, 32)
  end
end