local Entities = {} ; Entities.__index = Entities

function Entities.InjectEntity(func, ...)
  return {
    _isEntityInjector = true,
    _injectionTarget = func,
    _injectionArgs = {...}
  }
end

function Entities.InjectConfigured(func)
  return function(...) 
    return Entities.InjectEntity(func, ...)
  end
end

function Entities.new()
  local new = setmetatable({}, Entities)
  new._next = 1
  new._entities = {}
  new._systems = {}
  return new
end

local Entity = {} ; Entity.__index = Entity

function Entity:system()
  return self._entities
end

function Entity:each()
	return self:system():each()
end

function Entity:id()
  return self._eid	
end

function Entity:destroy(other)
  self:system():destroy(other or self)
end

function Entities:create(entity)
  if entity._entities then
    error("entity already has _entities tag")
  else
    setmetatable(entity, Entity)
    
    entity._entities = self
    entity._eid = self._next
    self._entities[entity._eid] = entity
    self._next = entity._eid + 1
    
    for k, v in pairs(entity) do
    	if type(v) == 'table' and v._isEntityInjector and type(v._injectionTarget) == 'function' then
        entity[k] = v._injectionTarget(entity, unpack(v._injectionArgs))
      end
    end
  end
end

function Entities:destroy(entity)
  if entity._entities == self then
    if self._entities[entity._eid] == entity then
      self._entities[entity._eid] = nil
      entity._entities = nil
      entity._eid = nil
    else
      error("entity was not at the index it should have been")
    end
  else
    error("entity is not in this system")
  end
end

function Entities:iterator(id)  
  while true do
    id = id + 1
    
    if id >= self._next then
      return nil -- end of entities
    elseif self._entities[id] then
      return id, self._entities[id]
    end 
    
    -- no entity at id, but there are unused ids beyond
  end
end

function Entities:each()
  return Entities.iterator, self, 0
end

return Entities