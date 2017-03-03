local util = game.strategy.util

local function ChaseStrategy(entity, opts) 
  entity.pos = entity.pos or vector.zero()
  entity.vel = entity.vel or vector.zero()
  
  local controller = entity.controller
  local maxAccel = opts.acceleration or 300
  local closeSpeed = opts.closeSpeed or 300
  
  return function(dt)
    local goal = util.getPlayerPosition(entity:system())
    local toGoal = goal - entity.pos
    local goalDir = toGoal:normal()
    
    if goal then
      if opts.matchVelocity then
        
        local pVel = util.getPlayerVelocity(entity:system()) or vector.zero()
        local relVel = pVel - entity.vel
        local ortho = goalDir:orthogonal()
        local opposedVel = ortho * (vector.dot(relVel, ortho))
        local targetVel = goalDir * closeSpeed + opposedVel
        local velError = targetVel - entity.vel
        
        controller:accelerate(velError:normal() * maxAccel)
        
      else
        local dir = toGoal:normal(true)
        local accel = dir * maxAccel      
        controller:accelerate(accel)
      end
    end
  end
end

return eonz.entities.InjectConfigured(ChaseStrategy)