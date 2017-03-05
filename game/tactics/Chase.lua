local tactics = game.tactics
local util = game.tactics.util

local CLOSE_SPEED = 100
local MAX_ACCEL = 300

return function(params)
  return function(env)
    local timer = 1 * math.random() + 1
    env.controller:setDamping(0.5)
    
    local function update(dt)
      timer = timer - dt
      
      local player = util.getPlayerPosition(env.system)
      local dir = (player - env.entity.pos):normal()
      local pVel = util.getPlayerVelocity(env.entity:system()) or vector.zero()
      local relVel = pVel - env.entity.vel
      local ortho = dir:orthogonal()
      local opposedVel = ortho * (vector.dot(relVel, ortho))
      local approachVel = dir * (vector.dot(relVel, dir))
      local targetVel = dir * CLOSE_SPEED + (opposedVel)
      
      if approachVel:length() < 0 then 
        targetVel = targetVel + approachVel
      end
      
      local velError = targetVel - env.entity.vel
      
      env.controller:accelerate(velError:normal() * MAX_ACCEL)
      
      if timer < 0 then
        util.completed(env, params)
      end
    end
    
    return update
  end
end