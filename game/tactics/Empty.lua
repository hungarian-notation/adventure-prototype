local tactics = game.tactics
local util = game.tactics.util

return function(params)
  -- This function initializes the tactic, but the tactic doesn't
  -- yet know anything about the entity that will be using it.
  
  return function(env)
    local entity = env.entity
    local controller = env.controller
    local system = env.system
    
    -- This function is called when the entity starts using the tactic.
    local timer = 0
    
    local function update(dt)
    	-- This function is called each tick.
      
      if timer > 1 then
        util.completed(env, params)
      end
    end
    
    local function event(event, args)
    	-- This function is called when an event is passed to the controller.
    end
    
    return update, event
  end
end