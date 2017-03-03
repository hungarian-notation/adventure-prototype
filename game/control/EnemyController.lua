local AVOID_IMPULSE = 1000
local DEFAULT_ACCEL = 100
local DEFAULT_DAMP = 0.1

local EnemyController = {} ; EnemyController.__index = EnemyController

function EnemyController.new(entity, args)
	local obj = setmetatable({}, EnemyController)
  
  args = args or {}
  
  obj._entity = entity
  obj._strategy = nil
  obj._dampening = args.dampening or DEFAULT_DAMP
  
  if args.strategy then obj:setStrategy(args.strategy(obj, entity)) end
  
	return obj
end

function EnemyController:system()
	return self._entity:system()
end

function EnemyController:entities()
	return self:system():each()
end

function EnemyController:getEntity()
	return self._entity
end

function EnemyController:setStrategy(strategy)
  self._strategy = strategy
end

function EnemyController:getStrategy()
	return self._strategy
end

function EnemyController:setDamping(damp)
  self._dampening = damp
end

function EnemyController:getDamping()
	return self._dampening
end

local function getAvoidanceAcceleration(entity, dt)
  local accel = vector.zero()
  
  for id, other in entity:each() do
    if other.radius and other.pos then
      if other ~= entity and (other.pos - entity.pos):length() < other.radius + entity.radius then
        local dir = (entity.pos - other.pos):normal(true)
        accel = accel + (dir * AVOID_IMPULSE)
      end
    end
  end
  
  return accel
end

function EnemyController:resetAcceleration()
	self._accel = vector.zero()
end

function EnemyController:accelerate(vector)
  self._accel = (self._accel or eonz.vector(0,0)) + vector
end

function EnemyController:act(dt)
  local entity = self._entity
  
  self:resetAcceleration()
  self:accelerate(getAvoidanceAcceleration(entity, dt))
  
	if entity.strategy then
    entity.strategy(dt)
  end
  
  entity.vel = (entity.vel or vector.zero()) + self._accel * dt
  entity.vel = entity.vel * self._dampening ^ dt
  entity.pos = entity.pos + entity.vel * dt
end

return function(args) return require('eonz.Entities').InjectEntity(function(entity) return EnemyController.new(entity, args) end) end