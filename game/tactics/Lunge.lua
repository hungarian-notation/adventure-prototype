local tactics = game.tactics
local util = game.tactics.util

local LUNGE_ACCEL = 1000
local TELEGRAPH_TIME = 0.2


return function(params)
  
  local accel = params.accel or LUNGE_ACCEL
  
  return function(env)
    
    local player = util.getPlayerPosition(env.system)
    local dir = (player - env.entity.pos):normal()
    
    local time = params.duration or (0.5 * math.random() + 0.1)
    local timer = -TELEGRAPH_TIME * time
    local winding_up = true
    
    local function update(dt)
      timer = timer + dt
      
      if timer < 0 then
        env.controller:accelerate(-dir * accel * 2)
      else
        if winding_up then
          env.entity.vel = vector()
          winding_up = false
        end
        
        env.controller:accelerate(dir * accel)
      end
        
      
      if timer > time then
        util.completed(env, params)
      end
    end
    
    return update
  end
end