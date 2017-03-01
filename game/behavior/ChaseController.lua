local Vector = require 'eonz.Vector'

return function()
  local CHASE_ACCEL = 100
  local CHASE_DAMP = 0.1
  local CHASE_IMPULSE = 500
  
  return function(e, dt, ecs)
    local target = nil
    
    for id, entity in ecs:each() do 
      if entity.isPlayer then target = entity ; break end 
    end
    
    -- impulse physics
    
    for id, entity in ecs:each() do
      if entity.radius and entity.pos then
        if entity ~= e and (entity.pos - e.pos):length() < entity.radius + e.radius then
          local dir = (e.pos - entity.pos):normal(true)
          e.vel = ((e.vel or Vector.zero()) + (dir * CHASE_IMPULSE * dt))
        end
      end
    end
    
    if target then
      local heading = (target.pos - e.pos):normal(true)
      e.vel = ((e.vel or Vector.zero()) + (heading * CHASE_ACCEL * dt)) * CHASE_DAMP ^ dt 
      e.pos = e.pos + e.vel * dt
    end
  end
end