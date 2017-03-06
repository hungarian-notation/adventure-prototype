local KNOCKBACK_FACTOR = 300
local KNOCKBACK_BASE = 300

local function EnemyTag(entity, params)
  params = (type(params) == 'table' and params) or {}
  
  local enemy = {}
  
  enemy.flicker = params.flicker or 0.5
  enemy.weight = params.weight or 1
  enemy.maxHealth = params.health or 3
  enemy.health = enemy.maxHealth
  enemy.active = false
  
  function enemy:on_update(dt)
    self.active = true
    self.on_update = nil
  end
  
  function enemy:on_attack(attack)
    if entity.flicker or not self.active then
      attack.cancelled = true
      return
    end
    
    local severity = math.min(1, math.max(0, attack.damage / self.maxHealth))
    
    game.res.sounds.hit:setPitch(1 + math.random() * 0.2)    
    
    love.audio.play(game.res.sounds.hit)
    
    self.health = self.health - attack.damage
    
    --entity:set('flicker', game.components.Flicker(enemy.flicker))
    
    entity:system():create(game.util.newDamageNumber(entity.pos + vector(0, -30), attack.damage))
  
    local knockback = (KNOCKBACK_BASE + KNOCKBACK_FACTOR * severity) / (self.weight / (attack.weight or 1))
    
    local direction = attack.direction or (entity.pos - attack.source.pos):normal()
    
    entity.vel = (direction * knockback)
    
    if self.health <= 0 then
      print('size: ', size)
      
      game.res.sounds.kill:setPitch(10 / entity.radius)
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
