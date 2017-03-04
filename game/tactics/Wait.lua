local tactics = game.tactics
local util = game.tactics.util

local function Wait(args)
  local inited = false
  
  return function(env)
      
    local timer = args.time or (1 * math.random() + 1)
    env.controller:setDamping(0.0001)
    
    return function(dt)
      timer = timer - dt
      
      if timer < 0 then
        env.controller:setTactic(args.on_done(env))
      end
    end
  end
end

return Wait