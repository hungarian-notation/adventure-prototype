local Entity = {} ; Entity.__index = Entity

Entity.INJECTOR_TAG = '_eonz_isEntityInjector'
Entity.INJECTOR_TARGET = '_eonz_injectorTarget'
Entity.INJECTOR_ARGS = '_eonz_injectionArgs'

function Entity.create(system, id, components)
  if components._meta then
    error("table already has _meta tag")
  else
    local entity = {}
    
    entity._meta = { _entities = system, _id = id }
    
    setmetatable(entity, Entity)
    
    for k, v in pairs(components) do
      entity:set(k, v)
    end
    
    return entity
  end
end

function Entity:system()
  return self._meta._entities
end

function Entity:each()
	return self:system():each()
end

function Entity:id()
  return self._meta._id	
end

function Entity:destroy(other)
  self:system():destroy(other or self)
end

function Entity:resolve(value)
  if type(value) == 'table' and value[Entity.INJECTOR_TAG] then
    return value[Entity.INJECTOR_TARGET](self, unpack(value[Entity.INJECTOR_ARGS]))
  else
    return value
  end
end

function Entity:set(key, value)
  rawset(self, key, self:resolve(value))
end

function Entity:add(component)
  table.insert(self, self:resolve(component))
end

function Entity:broadcast(event, ...)
	self:system():broadcast(self, event, ...)
end

function Entity:dispatch(event, ...)
  local targets = {}
  
  for k, v in pairs(self) do
    if (type(k) ~= 'string') or (k[1] ~= '_') then
      table.insert(targets, v)
    end
  end
  
  for k, v in ipairs(targets) do
    eonz.event.dispatch(v, event, ...)
  end
end

function Entity:onEvent(event, ...)
  self:dispatch(event, ...)
end

return Entity