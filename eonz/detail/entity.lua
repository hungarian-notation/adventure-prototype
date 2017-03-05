local Entity = {} ; Entity.__index = Entity

Entity.INJECTOR_TAG = '_eonz_isEntityInjector'
Entity.INJECTOR_TARGET = '_eonz_injectorTarget'
Entity.INJECTOR_ARGS = '_eonz_injectionArgs'

function Entity.create(system, id, components)
  if components._entities then
    error("table already has _entities tag")
  else
    local entity = {}
    
    entity._entities = system
    entity._eid = id
    
    setmetatable(entity, Entity)
    
    for k, v in pairs(components) do
      entity:set(k, v)
    end
    
    return entity
  end
end

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

function Entity:dispatch(event, ...)
  self:on_event(event, ...)
end

function Entity:on_event(name, ...)
  for k, v in pairs(self) do
    eonz.event.dispatch(v, name, ...)
  end
end

return Entity