local function Controller(e, keys, screenEffects)
  
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
  
  local DODGE_TIME = 0.5
  local DODGE_ACCEL = 1800
  
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
  
  local function getDirection() 
    return (vector.new(love.mouse.getPosition()) - e.pos):normal()
  end
  
  local function attackRanged(dt)
    
    local function hitCallback(projectile, target, ecs)
      if target.enemy then
        local event = { damage=2, source=e }
        target:dispatch(game.event.Attack, event)
        return event.cancelled
      end
      
      return true
    end
  
    local dir = getDirection()
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
  
  local function attackMelee(dt)
    
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
                
    
        if dist <= hitDist or love.keyboard.isDown('q') then
          local angleTo = toEntity:angle()
          local lowerAngle = e.sword.dir:angle() - e.sword.theta / 2
          local relAngle = normalize(angleTo - lowerAngle)
          
          if relAngle < e.sword.theta or love.keyboard.isDown('q') then
            entity:dispatch(game.event.Attack, { damage=1, source=e })
          end
        end
      end
    end
  end
  
  local function dodge()
    if e.sword then
      e.sword = nil
    end
    
    local dir = e.vel:normal()
    e.dodge = { dir=dir, time=DODGE_TIME, radius=e.radius }    
    e.radius = e.radius * 2 / 3
  end
  
  local function onUpdate(table, dt)
    
    if not e.dodge then
      for id, entity in e:each() do
        if entity.enemy then
          if (entity.pos - e.pos):length() < ((entity.radius or 0) + (e.radius or 0)) then
            screenEffects.hurtFlash = 0.2
          end
        end
      end
    end
    
    -- Cooldowns
    
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
    
    if not e.sword and not e.dodge and love.mouse.isDown(1) then
      attackMelee(dt)
    end
    
    -- Bow Control
    
    if not e.bowReload and love.mouse.isDown(2) then
      attackRanged(dt)
      e.bowReload = BOW_RELOAD
    end
    
    -- Dodge Control
    
    if not e.dodge and love.keyboard.isDown(keys.dodge) then
      dodge()
    end
    
    if e.dodge then
      e.dodge.time = e.dodge.time - dt
      if e.dodge.time <= 0 then
        e.radius = e.dodge.radius
        e.dodge = nil
      else
        e.vel = e.vel + (e.dodge.dir * DODGE_ACCEL * dt)
      end
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
    
    if not e.dodge and control:length2() > 0 then
      local accel = control * PLAYER_ACCEL * dt
      e.vel = e.vel + (control * PLAYER_ACCEL * dt)
    end
    
    e.pos = e.pos + ((e.vel or vector.zero()) * dt)
    e.vel = (e.vel or vector.zero()) * (anyControl and PLAYER_DAMP or PLAYER_NO_CONTROL_DAMP) ^ dt
  end
  
  return { onUpdate = onUpdate }
end

return eonz.entities.Injector(Controller)