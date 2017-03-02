return function(hitCallback)
  return function(e, dt, ecs)
    e.pos = e.pos + e.vel * dt
    e.age = (e.age or 0) + dt
    
    for id, target in ecs:each() do
      if target ~= e and target.pos then
        local sep = (target.pos - e.pos):length() - ((target.radius or 0) + (e.radius or 0))
        if sep <= 0 then
          local continue = hitCallback(e, target, ecs)
          if not continue then
            ecs:destroy(e)
            return
          end
        end
      end
    end
    
    if e.age > 10 then 
      -- This is a quick and dirty cleanup for projectiles that miss
      ecs:destroy(e)
    end
  end
end