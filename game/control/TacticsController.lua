local AVOID_IMPULSE = 1000
local DEFAULT_ACCEL = 100
local DEFAULT_DAMP = 0.1

local dispatchEvent = eonz.event.dispatch

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

local TacticsController = {} ; TacticsController.__index = TacticsController

function TacticsController.new(entity, args)
	local obj = setmetatable({}, TacticsController)
  
  args = args or {}
  
  obj._entity = entity
  obj._dampening = args.dampening or DEFAULT_DAMP
  
  obj._env = {
    entity = entity,
    controller = obj,
    system = entity:system()
  }
  
  if args.strategy then obj:setStrategy(args.strategy) end
  
	return obj
end

function TacticsController:system()
	return self._entity:system()
end

function TacticsController:entity()
	return self._entity
end

function TacticsController:setStrategy(strategy)
	local tactic, listener = strategy(self._env)
  self._listener = listener
  self:setTactic(tactic)
end

function TacticsController:setTactic(protoTactic)
  self._proto_tactic = protoTactic
end

function TacticsController:setDamping(damp)
  self._dampening = damp
end

function TacticsController:getDamping()
	return self._dampening
end

function TacticsController:resetAcceleration()
	self._accel = vector.zero()
end

function TacticsController:accelerate(vector)
  self._accel = (self._accel or eonz.vector(0,0)) + vector
end

function TacticsController:onEvent(event, args)
  if self._listener then dispatchEvent(self._listener, event, args) end
  if self._tactic_listener then dispatchEvent(self._tactic_listener, event, args) end
end

function TacticsController:onUpdate(dt)
  local entity = self._entity
  
  assert(type(dt) == 'number', 'expected number, found ' ..type(dt))
  
  self:resetAcceleration()
  self:accelerate(getAvoidanceAcceleration(entity, dt))
  
	if self._proto_tactic then
    self._tactic_update_function, self._tactic_listener = self._proto_tactic(self._env)
    self._proto_tactic = nil
  end
  
  if self._tactic_update_function then
    self._tactic_update_function(dt)
  end
  
  entity.vel = (entity.vel or vector.zero()) + self._accel * dt
  entity.vel = entity.vel * self._dampening ^ dt
  entity.pos = entity.pos + entity.vel * dt
end

return function(args) return require('eonz.Entities').InjectorClosure(function(entity) return TacticsController.new(entity, args) end) end