local tactics = game.tactics
local util = game.tactics.util

local LUNGE_IMPULSE = 1000

return function(args)
  return function(env)
    local player = util.getPlayerPosition(env.system)
    local dir = (player - env.entity.pos):normal()
    local timer = 0.5 * math.random() + 0.1
    env.controller:setDamping(0.5)
    
    local function update(dt)
      timer = timer - dt
      
      env.controller:accelerate(dir * LUNGE_IMPULSE)
      
      if timer < 0 then
        env.controller:setTactic(args.on_done(env))
      end
    end
    
    return update
  end
end