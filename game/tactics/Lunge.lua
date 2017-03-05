local tactics = game.tactics
local util = game.tactics.util

local LUNGE_ACCEL = 1000

return function(params)
  
  local accel = params.accel or LUNGE_ACCEL
  
  return function(env)
    local player = util.getPlayerPosition(env.system)
    local dir = (player - env.entity.pos):normal()
    local timer = params.duration or (0.5 * math.random() + 0.1)
    
    local function update(dt)
      timer = timer - dt
      env.controller:accelerate(dir * accel)
      
      if timer < 0 then
        util.completed(env, params)
      end
    end
    
    return update
  end
end