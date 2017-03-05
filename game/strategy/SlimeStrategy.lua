local LUNGE_ACCEL = 700
local CHASE_ACCEL = 300

return function(params)
  
  local agility = params.agility or 1
  local endurance = 1 / ((agility + 2) / 3)
  
  local lungeAccel = LUNGE_ACCEL * agility
  local chaseAccel = CHASE_ACCEL * agility
  
  return function(env)
    local AfterWaiting, AfterChasing, AfterLunging
    
    local phases = {}
    local tactics = {}
    
    function tactics.Wait(time)
      return game.tactics.Wait { on_completed=phases.StartAttack, time=time }
    end
    
    function tactics.Chase()
      local chaseDuration = (1 * math.random() + 1) * endurance
      return game.tactics.Chase { on_completed=phases.AfterChase, accel=chaseAccel, duration=chaseDuration }
    end
    
    function tactics.Lunge()
      local lungeDuration = (0.5 * math.random() + 0.1) * endurance
      return game.tactics.Lunge { on_completed=phases.AfterAttack, accel=lungeAccel, duration=lungeDuration  }
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
      return tactics.Wait(1.0 / endurance)
    end
    
    local function on_event(event, args) 
      if event == game.event.injured then        
        env.controller:setTactic(phases.AfterInjured())
      end
    end
    
    return tactics.Wait(0.5), on_event
  end
end