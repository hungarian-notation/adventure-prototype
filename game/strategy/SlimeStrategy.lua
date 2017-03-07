local util = game.tactics.util

local LUNGE_ACCEL = 500
local LUNGE_DUR = 0.2
local CHASE_ACCEL = 300

local LUNGE_RANGE = 200

local LUNGE_ADJUST = 5

return function(params)
  
  local agility = params.agility or 1
  local endurance = 1 / ((agility + 2) / 3)
  
  local lungeAccel = LUNGE_ACCEL * ((agility + LUNGE_ADJUST) / (LUNGE_ADJUST + 1))
  local chaseAccel = CHASE_ACCEL * agility
  
  return function(env)
    local AfterWaiting, AfterChasing, AfterLunging
    
    local phases = {}
    local tactics = {}
    
    function tactics.Wait(time)
      return game.tactics.Wait { onCompleted=phases.StartAttack, time=time or 1.0 / (endurance * 2) }
    end
    
    function tactics.Chase()
      local chaseDuration = (1 * math.random() + 1) * endurance
      return game.tactics.Chase { onCompleted=phases.AfterChase, accel=chaseAccel, duration=chaseDuration }
    end
    
    function tactics.Lunge()
      local toPlayer = util.getPlayer(env.system) - env.entity.pos
      local dist = toPlayer:length()
      
      if dist < LUNGE_RANGE then
        local lungeDuration = (LUNGE_DUR) * endurance
        return game.tactics.Lunge { onCompleted=phases.AfterAttack, accel=lungeAccel, duration=lungeDuration  }
      else
        return tactics.Wait()
      end
    end  
    
    function phases.StartAttack()
      if env.entity.flicker then
        return tactics.Wait(0.1)
      elseif math.random() > 0.5 then
        return tactics.Chase()
      else
        return tactics.Lunge()
      end
    end
    
    function phases.AfterChase()
      return tactics.Lunge()
    end
    
    function phases.AfterAttack()
      return tactics.Wait(math.random() * 0.5 + 0.25)
    end
    
    function phases.AfterInjured()
      return tactics.Wait()
    end
    
    local function onEvent(event, args) 
      if event == game.event.Injured then        
        env.controller:setTactic(phases.AfterInjured())
      end
    end
    
    return tactics.Wait(0.5), onEvent
  end
end