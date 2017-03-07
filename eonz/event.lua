local event = {}

local HANDLER_PREFIX = 'on'
local DEFAULT_HANDLER = 'onEvent'

function event.getHandlerFor(eventName) return HANDLER_PREFIX..eventName end

function event.isListener(listener)
  -- Tests if the value provided is a table with one or more
  -- listener functions
  
  if type(listener) == 'table' then
    for k, v in pairs(listener) do
      if type(k) == 'string' and type(v) == 'function' then
        local is_general = k == DEFAULT_HANDLER
        local is_specific = #k > #HANDLER_PREFIX and k:sub(1, #HANDLER_PREFIX) == HANDLER_PREFIX
        
        if is_general or is_specific then
          return true
        end
      end
    end
    
    return false  
  else
    return false
  end
end

function event.dispatch(listener, name, ...) 
	local direct = event.getHandlerFor(name)
  
  if type(listener) == 'table' then
    if type(listener[direct]) == 'function' then      
      return listener[direct](listener, ...)
    elseif type(listener[DEFAULT_HANDLER]) == 'function' then
      return listener[DEFAULT_HANDLER](listener, name, ...)
    end
  elseif type(listener) == 'function' then
    listener(name, ...)
  end
end

return event