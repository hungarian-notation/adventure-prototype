local path = require 'eonz.path' -- this must be a raw require

local Namespace = {}

local ROOT_NAMESPACE = nil
local ROOT_NAMESPACE_CACHE = {}

function Namespace.root()
  if not ROOT_NAMESPACE then
    ROOT_NAMESPACE = Namespace.new(nil, nil, true)
  end
  return ROOT_NAMESPACE
end

function Namespace.new(name, parent, root)
	return setmetatable({
    _name = name or root and "<root>" or error("name must not be nil"),
    _parent = parent and (not parent:isRoot() and parent or nil) or nil,
    _loaded = {},
    _isRoot = root or false,
    _keystore = {}
  }, Namespace)
end

--

function Namespace:__call(key) return self[key] end
 
function Namespace:__index(key)
  return self._loaded[key] or Namespace[key] or self._keystore[key] or self:get(key)
end

function Namespace:check_sanity()
  assert(rawget(self, "_name")  ~= nil, "table has no _name key")
  assert(rawget(self, "_loaded") ~= nil, "table has no _loaded key")
end

function Namespace:get(key)
  self:check_sanity()
  return rawget(self, '_loaded')[key] or self:_load(key)
end

function Namespace:_load(key)
  self:check_sanity()
  local value
  
	if self:hasModule(key) then
    local path = self:getModuleRequirePath(key)
    value = require(path)
    eonz.log("required " .. path)
  else
    value = self:getNamespace(key) 
    if not value:exists() then
      error('no such module or namespace: ' .. value:getRequirePath())
    end
  end
  
  self._loaded[key] = value
  return value
end

-- 

function Namespace:setVariable(key, value)
  self._keystore[key] = value
end

function Namespace:getVariable(key)
  return self._keystore[key]
end

-- 

function Namespace:isRoot() 
  return self._isRoot
end

function Namespace:exists()
	return love.filesystem.isDirectory(self:getPath())
end

function Namespace:getParent()
	return rawget(self, '_parent')
end

function Namespace:getName()
	return self._name
end

function Namespace:getRequirePath()
  return (self:getParent() and (self:getParent():getRequirePath() .. '.' .. self:getName()) or self:getName())
end

function Namespace:getPath()
  return self:isRoot() and "" or self:getParent() and path.join(self:getParent():getPath(), self:getName()) or self:getName()
end

function Namespace:getNamespace(nsName)
  return Namespace.new(nsName, self)
end

function Namespace:hasNamespace(nsName)
  return self:getNamespace(nsName):exists()
end

function Namespace:hasModule(mName)
  return love.filesystem.isFile(self:getModulePath(mName))
end

function Namespace:getModuleRequirePath(mName)
  return self:isRoot() and mName or (self:getRequirePath() .. '.' .. mName)
end

function Namespace:getModulePath(mName)
  local file = mName .. ".lua"
  return self:isRoot() and file or path.join(self:getPath(), file)
end

return Namespace.root()