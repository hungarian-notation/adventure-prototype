return function(env)
  local AfterWaiting, AfterChasing, AfterLunging
  
  local phases = {}
  local tactics = {}
  
  function tactics.Wait(time)
    return game.tactics.Wait { on_completed = phases.StartAttack, time=time }
  end
  
  function tactics.Chase()
    return game.tactics.Chase { on_completed = phases.AfterChase }
  end
  
  function tactics.Lunge()
    return game.tactics.Lunge { on_completed = phases.AfterAttack }
  end  
  
  function phases.StartAttack()
    if env.entity._oldcolor then
      env.entity.color = env.entity._oldcolor
      env.entity._oldcolor = nil
    end
      
    if math.random() > 0.5 then
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
    return tactics.Wait(2.0)
  end
  
  local function on_event(event, args) 
    if event == game.event.injured then
      
      if env.entity.color and not env.entity._oldcolor then
        env.entity._oldcolor = env.entity.color
        env.entity.color = {0xFF, 0xAA, 0xAA}
      end
      
      env.controller:setTactic(phases.AfterInjured())
    end
  end
  
  return tactics.Wait(0.5), on_event
end