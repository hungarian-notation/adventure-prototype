local KNOCKBACK_FACTOR = 300
local KNOCKBACK_BASE = 300

local function EnemyTag(entity, params)
  params = (type(params) == 'table' and params) or {}
  
  local enemy = {}
  
  enemy.weight = params.weight or 1
  enemy.maxHealth = params.health or 3
  enemy.health = enemy.maxHealth
  
  function enemy:on_attack(attack)
    
    game.res.sounds.hit:setPitch(1 + math.random() * 0.2)    
    love.audio.play(game.res.sounds.hit)
    
    self.health = self.health - attack.damage
    
    entity:system():create(game.util.newDamageNumber(entity.pos + vector(0, -30), attack.damage))
  
    local knockback = (KNOCKBACK_BASE + KNOCKBACK_FACTOR * math.min(1, math.max(0, attack.damage / self.maxHealth))) / (self.weight / (attack.weight or 1))
    local direction = attack.direction or (entity.pos - attack.source.pos):normal()
    
    entity.vel = (direction * knockback)
    
    if self.health <= 0 then
      game.res.sounds.kill:play()
      eonz.event.dispatch(entity, game.event.death)  
      entity:destroy()
    else
      eonz.event.dispatch(entity, game.event.injured, { damage=attack.damage })
    end
  end
  
  return enemy
end

return eonz.entities.Injector(EnemyTag)
