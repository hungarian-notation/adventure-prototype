return eonz.entities.Injector( function(e, hitCallback)
  return { onUpdate = function(event, dt)
    e.pos = e.pos + e.vel * dt
    e.age = (e.age or 0) + dt
    
    for id, target in e:each() do
      if target ~= e and target.pos then
        local sep = (target.pos - e.pos):length() - ((target.radius or 0) + (e.radius or 0))
        if sep <= 0 then
          local continue = hitCallback(e, target, ecs)
          if not continue then
            e:system():destroy(e)
            return
          end
        end
      end
    end
    
    if e.age > 10 then 
      -- This is a quick and dirty cleanup for projectiles that miss
      e:system():destroy(e)
    end
  end }
end )