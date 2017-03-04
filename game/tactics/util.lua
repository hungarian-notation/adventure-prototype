local util = {}

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

return eonz.table.seal(util)