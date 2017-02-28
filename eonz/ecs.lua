local ECS = {} ; ECS.__index = ECS

function ECS.new()
  local new = setmetatable({}, ECS)
  
  new._next = 1
  new._entities = {}
  new._systems = {}
  
  return new
end

function ECS:create(entity)
  if entity._ecs then
    error("entity already has _ecs tag")
  else
    entity._ecs = self
    entity._eid = self._next
    
    self._entities[entity._eid] = entity
    self._next = entity._eid + 1
  end
end

function ECS:destroy(entity)
  if entity._ecs == self then
    if self._entities[entity._eid] == entity then
      self._entities[entity._eid] = nil
      entity._ecs = nil
      entity._eid = nil
    else
      error("entity was not at the index it should have been")
    end
  else
    error("entity is not in this system")
  end
end

function ECS:iterator(id)  
  
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

function ECS:each()
  return ECS.iterator, self, 0
end

return ECS