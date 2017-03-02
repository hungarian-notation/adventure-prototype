local FLOAT_SPEED = 16

return function()
  return function(e, dt, ecs)
    e.time = e.time - dt
    e.pos.y = e.pos.y - FLOAT_SPEED * dt
    
    if e.time <= 0 then
      ecs:destroy(e)
    end
  end
end