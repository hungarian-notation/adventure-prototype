return function()
  local AfterWaiting, AfterChasing, AfterLunging
  
  AfterWaiting = function(env)
    if math.random() > 0.5 then
      return game.tactics.Chase { on_done = AfterChasing }
    else
      return game.tactics.Lunge { on_done = AfterLunging }
    end
  end
  
  AfterChasing = function(env)
    return game.tactics.Lunge { on_done = AfterLunging }
  end
  
  AfterLunging = function(env)
    return game.tactics.Wait {
      time    = math.random() * 0.5 + 0.25,
      on_done = AfterWaiting 
    }
  end
  
  print("returning strategy hook")
  
  return game.tactics.Wait { on_done = AfterWaiting }
end