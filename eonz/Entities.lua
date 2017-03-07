local Entity = eonz.detail.entity

local Entities = {} ; Entities.__index = Entities

function Entities.EventHandler(event, handler)
	return { [eonz.event.getHandlerFor(event)] = handler }
end

function Entities.InjectorClosure(func, ...)
  return {
    [Entity.INJECTOR_TAG] = true,
    [Entity.INJECTOR_TARGET] = func,
    [Entity.INJECTOR_ARGS] = {...}
  }
end

function Entities.Injector(func)
  return function(...) 
    return Entities.InjectorClosure(func, ...)
  end
end

function Entities.new()
  local new = setmetatable({}, Entities)
  new._next = 1
  new._entities = {}
  new._systems = {}
  return new
end

function Entities:create(components)
  local id = self._next
  local entity = Entity.create(self, id, components)
  self._entities[id] = entity
  self._next = id + 1
  return entity
end

function Entities:destroy(entity)
  if entity._meta._entities == self then    
    if self._entities[entity._meta._id] == entity then
      entity:dispatch('destroyed')
      self._entities[entity._meta._id] = nil
      entity._meta = nil
    else
      error("entity was not at the index it should have been")
    end
  else
    error("entity is not in this system")
  end
end

function Entities:broadcast(src, event, ...)
	for id, entity in self:each() do
    if entity ~= src then
      entity:dispatch(event, ...)
    end
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