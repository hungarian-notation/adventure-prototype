local AVOID_IMPULSE = 1000
local DEFAULT_ACCEL = 100
local DEFAULT_DAMP = 0.1

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
  
  if args.tactic then obj:setTactic(args.tactic) end
  
	return obj
end

function TacticsController:system()
	return self._entity:system()
end

function TacticsController:entity()
	return self._entity
end

function TacticsController:setTactic(protoTactic)
  self._protoTactic = protoTactic
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

function TacticsController:act(dt)
  local entity = self._entity
  
  self:resetAcceleration()
  self:accelerate(getAvoidanceAcceleration(entity, dt))
  
	if self._protoTactic then
    self._tUpdate, self._tEvent = self._protoTactic(self._env)
    self._protoTactic = nil
  end
  
  if self._tUpdate then
    self._tUpdate(dt)
  end
  
  entity.vel = (entity.vel or vector.zero()) + self._accel * dt
  entity.vel = entity.vel * self._dampening ^ dt
  entity.pos = entity.pos + entity.vel * dt
end

return function(args) return require('eonz.Entities').InjectEntity(function(entity) return TacticsController.new(entity, args) end) end