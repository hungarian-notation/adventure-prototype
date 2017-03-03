local table = {}

local function reject_sealed(t, k, v)
  error("can't set '" .. k .. "'; table is sealed")
end

function table.seal(t)
	local metatable = getmetatable(t)
  
  if not metatable then
    metatable = {}
    setmetatable(t, metatable)
  end
  
  if metatable.__newindex and metatable.__newindex ~= reject_sealed then
    error("table already defines a __newindex metamethod")
  else
    metatable.__newindex = reject_sealed
  end
  
  return t
end

return table