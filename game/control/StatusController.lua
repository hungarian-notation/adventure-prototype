local FLOAT_SPEED = 16

local function StatusController(e)
  return { on_update = function(event, dt)
    e.time = e.time - dt
    e.pos.y = e.pos.y - FLOAT_SPEED * dt
    
    if e.time <= 0 then
      e:system():destroy(e)
    end
  end }
end

return eonz.entities.Injector(StatusController)