local util = game.strategy.util

local LUNGE_IMPULSE = 1000
local CLOSE_SPEED = 100
local MAX_ACCEL = 300

local function LungeStrategy(entity, opts)
  local controller = entity.controller
  local tactics = {}
  
  function tactics.Chase()
    local timer = 1 * math.random() + 1
    
    controller:setDamping(0.5)
    
    entity.tactic = function(dt)
      timer = timer - dt
      
      local player = util.getPlayerPosition(entity:system())
      local dir = (player - entity.pos):normal()
    
      local pVel = util.getPlayerVelocity(entity:system()) or vector.zero()
      local relVel = pVel - entity.vel
      local ortho = dir:orthogonal()
      local opposedVel = ortho * (vector.dot(relVel, ortho))
      local targetVel = dir * CLOSE_SPEED + opposedVel
      local velError = targetVel - entity.vel
      
      controller:accelerate(velError:normal() * MAX_ACCEL)
      
      if timer < 0 then
        if math.random() > 0.2 then tactics.Wait() else tactics.Lunge() end
      end
    end
  end
  
  function tactics.Lunge()
    local player = util.getPlayerPosition(entity:system())
    local dir = (player - entity.pos):normal()
    local timer = 0.5 * math.random() + 0.1
    
    controller:setDamping(0.5)
    
    entity.tactic = function(dt)
      timer = timer - dt
      
      controller:accelerate(dir * LUNGE_IMPULSE)
      
      if timer < 0 then
        tactics.Wait()
      end
    end
  end

  function tactics.Wait(time)
    local timer = (1 * math.random() + 1)
    
    controller:setDamping(0.0001)
    
    entity.tactic = function(dt)
      timer = timer - dt
        
      if timer < 0 then
        if math.random() > 0.5 then tactics.Chase() else tactics.Lunge() end
      end
    end
  end

  tactics.Wait()
  
  return function(dt) 
    entity.tactic(dt) 
  end
end

return eonz.entities.InjectConfigured(LungeStrategy)