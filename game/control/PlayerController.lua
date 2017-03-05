local function Controller(e, keys, spawnEnemy, screenEffects, fonts)
  
  local PLAYER_ACCEL = 1000
  local PLAYER_DAMP = 0.01
  local PLAYER_NO_CONTROL_DAMP = 0.0001
  
  local SWORD_SWING_TIME = 0.05
  local SWORD_HOLD_TIME = 0.4
  local SWORD_ANGLE = math.pi * 0.8 
  local SWORD_RADIUS = 58
  local SWORD_INNER_RADIUS = 24
  
  local BOW_SHOT_SPEED = 800
  local BOW_SHOT_RADIUS = 8
  local BOW_SHOT_MASS = 0.2
  local BOW_RELOAD = 1
  
  local SWING_VELOCITY_LOSS = 0.25
  local KNOCK_BACK_IMPULSE = 300
  
  local nextSwingDirection = 1
  
  local function Sword(dir, color)
    
    -- alternate swing directions
    
    local swingDir = nextSwingDirection
    nextSwingDirection = nextSwingDirection * -1
    
    return {
      dir       = dir, -- normal vector that bisects the swing arc
      swing     = swingDir, -- the sign of the swing motion
      
      time      = 0,
      swingTime = SWORD_SWING_TIME, -- the duration of the swing in seconds
      holdTime  = SWORD_HOLD_TIME, -- the duration of the swing in seconds
      
      theta     = SWORD_ANGLE, -- the total angle covered by the swing
      radius    = { outer=SWORD_RADIUS, inner=SWORD_INNER_RADIUS }, -- the size of the swing in pixels
      color     = color or {255, 0, 0}
      
    }
    
  end
  
  local function normalize(angle)
    while angle > math.pi * 2 do
      angle = angle - math.pi * 2
    end
    
    while angle < 0 do
      angle = angle + math.pi * 2
    end
    
    return angle
  end
  
  local function getDirection(e) 
    return (vector.new(love.mouse.getPosition()) - e.pos):normal()
  end
  
  local function hitCallback(projectile, target, ecs)
    if target.enemy then
      
      
      target:dispatch(game.event.attack, { damage=2, source=e })
      
      --[[
      
      target.enemy.health = target.enemy.health - 1
      
      love.audio.play(game.res.sounds.hit)
      
      local damage = math.floor(math.random() * 20)
      projectile:system():create(game.util.newDamageNumber(target.pos + vector(0, -30), damage))
            
      local knockBack = projectile.vel * (projectile.mass or 0) / target.enemy.mass
      target.vel = (target.vel or vector.zero()) + knockBack
            
      if target.enemy.health <= 0 then
        projectile:system():destroy(target)
        game.res.sounds.kill:play()
        spawnEnemy(projectile:system())
      end
      
      ]]
      
      return false
    end
    
    return true
  end
  
  local function attackRanged(e, dt)
    local dir = getDirection(e)
    local vel = dir * BOW_SHOT_SPEED
    
    love.audio.play(game.res.sounds.shoot)
    
    e:system():create {
      pos = e.pos,
      vel = vel,
      mass = BOW_SHOT_MASS,
      controller = game.control.ProjectileController(hitCallback),
      drawable = game.gfx.CircleDrawable(),
      radius = BOW_SHOT_RADIUS,
      color = {0xFF, 0x00, 0x00}
    }
  end
  
  local function attackMelee(e, dt)
    
    local dir = getDirection(e)
    
    e.vel = e.vel * SWING_VELOCITY_LOSS
    e.sword = Sword(dir)
    
    local hitDist = SWORD_RADIUS 
    
    game.res.sounds.slash:setPitch(1 + math.random() * 0.2)    
    love.audio.play(game.res.sounds.slash)
      
    for id, entity in e:each() do
      if entity.enemy then
        
        local toEntity = entity.pos - e.pos
        local dist = toEntity:length() - (entity.radius * 2) 
                
    
        if dist <= hitDist then
          local angleTo = toEntity:angle()
          local lowerAngle = e.sword.dir:angle() - e.sword.theta / 2
          local relAngle = normalize(angleTo - lowerAngle)
          
          if relAngle < e.sword.theta then
            entity:dispatch(game.event.attack, { damage=1, source=e })
          end
        end
      end
    end
  end
  
  local function on_update(table, dt)
    
    for id, entity in e:each() do
      if entity.enemy then
        if (entity.pos - e.pos):length() < ((entity.radius or 0) + (e.radius or 0)) then
          screenEffects.hurtFlash = 0.2
        end
      end
    end
    
    if e.sword then      
      e.sword.time = e.sword.time + dt
      if e.sword.time >= e.sword.holdTime then
        e.sword = nil
      end
    end
    
    if e.bowReload then
      e.bowReload = e.bowReload - dt
      if e.bowReload <= 0 then
        e.bowReload = nil
      end
    end
    
    -- Sword Control
    
    if not e.sword and love.mouse.isDown(1) then
      attackMelee(e, dt, ecs)
    end
    
    if not e.bowReload and love.mouse.isDown(2) then
      attackRanged(e, dt, ecs)
      e.bowReload = BOW_RELOAD
    end
    
    -- Movement Control
    
    local control = vector()
    local anyControl = false
    
    if love.keyboard.isDown(keys.left) then
      control.x = control.x - 1
      anyControl = true
    end
    
    if love.keyboard.isDown(keys.right) then
      control.x = control.x + 1
      anyControl = true
    end
    
    if love.keyboard.isDown(keys.up) then
      control.y = control.y - 1
      anyControl = true
    end
    
    if love.keyboard.isDown(keys.down) then
      control.y = control.y + 1
      anyControl = true
    end
    
    if control:length2() > 0 then
      local accel = control * PLAYER_ACCEL * dt
      e.vel = e.vel + (control * PLAYER_ACCEL * dt)
    end
    
    e.pos = e.pos + ((e.vel or vector.zero()) * dt)
    e.vel = (e.vel or vector.zero()) * (anyControl and PLAYER_DAMP or PLAYER_NO_CONTROL_DAMP) ^ dt
  end
  
  return { on_update = on_update }
end

return eonz.entities.Injector(Controller)