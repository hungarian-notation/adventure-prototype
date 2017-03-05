local util = {}

local dispatch = eonz.event.dispatch

function util.getPlayerPosition(entities)
  for id, entity in entities:each() do
    if entity.isPlayer then return entity.pos end
  end
  return nil
end

function util.getPlayerVelocity(entities)
  for id, entity in entities:each() do
    if entity.isPlayer then return entity.vel end
  end
  return nil
end

function util.message(env, handlers, name, ...)
  return dispatch(env.controller, name, ...) or dispatch(handlers, name, ...)
end

function util.completed(env, handlers)
  env.controller:setTactic(util.message(env, handlers, 'completed'))
end

return eonz.table.seal(util)