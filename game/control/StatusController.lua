local FLOAT_SPEED = 16

return function()
  return function(e, dt)
    e.time = e.time - dt
    e.pos.y = e.pos.y - FLOAT_SPEED * dt
    
    if e.time <= 0 then
      e:system():destroy(e)
    end
  end
end