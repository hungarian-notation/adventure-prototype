local function EXPORT_GLOBAL(key, value)
  _G[key] = value
  eonz.log('exported "' .. key .. '" to the global table')
end

local function EXPORT_OPT_GLOBAL(opt, def, value) 
  if opt then
    local key = type(opt) == 'string' and opt or def
    EXPORT_GLOBAL(key, value)
  end
end

-- # Optional Exports
-- To export these optional packages into the global namespace, set
-- their opts key to a truthy value when calling this function. If
-- you set the value to a string, that string is the name the package
-- will be exported as. If you set the value to `true`, they will be
-- exported under their default name.
  
return function(opts) 
  local root_namespace = require 'eonz.namespace'
  
  if opts.debug_messages then
    root_namespace.eonz:setVariable("DEBUG", true)
    root_namespace.eonz:setVariable("log", function (...) print (...) end)
  else
    root_namespace.eonz:setVariable("log", function () end)
  end
    
  EXPORT_GLOBAL("eonz", root_namespace.eonz)
  EXPORT_OPT_GLOBAL(opts.global_vector, "vector", root_namespace.eonz.vector)
  EXPORT_OPT_GLOBAL(opts.global_namespace, "lib", root_namespace)
end