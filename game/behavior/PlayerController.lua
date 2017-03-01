local Vector = require "eonz.Vector"

return function(keys, spawnEnemy, screenEffects)
  local PLAYER_ACCEL = 1000
  local PLAYER_DAMP = 0.01
  
  local SWORD_SWING_TIME = 0.05
  local SWORD_HOLD_TIME = 0.4
  
  local SWORD_ANGLE = math.pi * 0.8
  local SWORD_RADIUS = 58
  local SWORD_INNER_RADIUS = 24
  
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
  
  local function attack(e, dt, ecs)
    local dir = (Vector.new(love.mouse.getPosition()) - e.pos):normal()
    
    e.vel = e.vel * SWING_VELOCITY_LOSS
    e.sword = Sword(dir)
    
    local hitDist = SWORD_RADIUS 
    
    for id, entity in ecs:each() do
      if entity.enemy then
        
        local toEntity = entity.pos - e.pos
        local dist = toEntity:length() - (entity.radius * 2) 
                
        if dist <= hitDist then
          local angleTo = toEntity:angle()
          local lowerAngle = e.sword.dir:angle() - e.sword.theta / 2
          local relAngle = normalize(angleTo - lowerAngle)
          
          if relAngle < e.sword.theta then
            entity.enemy.health = entity.enemy.health - 1
            
            if entity.enemy.health <= 0 then
              ecs:destroy(entity)
              
              spawnEnemy(ecs)
            else
              local knockBack = (e.sword.dir + toEntity:normal()) / 2 * KNOCK_BACK_IMPULSE / entity.enemy.mass
              entity.vel = (entity.vel or Vector.zero()) + knockBack
            end
          end
        end
      end
    end
  end
  
  return function(e, dt, ecs)
    for id, entity in ecs:each() do
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
    
    -- Sword Control
    
    if not e.sword and love.mouse.isDown(1) then
      attack(e, dt, ecs)
    end
    
    -- Movement Control
    
    local control = Vector()
    
    if love.keyboard.isDown(keys.left) then
      control.x = control.x - 1
    end
    
    if love.keyboard.isDown(keys.right) then
      control.x = control.x + 1
    end
    
    if love.keyboard.isDown(keys.up) then
      control.y = control.y - 1
    end
    
    if love.keyboard.isDown(keys.down) then
      control.y = control.y + 1
    end
    
    if control:length2() > 0 then
      local accel = control * PLAYER_ACCEL * dt
      e.vel = e.vel + (control * PLAYER_ACCEL * dt)
    end
    
    e.pos = e.pos + ((e.vel or Vector.zero()) * dt)
    e.vel = (e.vel or Vector.zero()) * PLAYER_DAMP ^ dt
  end
end
