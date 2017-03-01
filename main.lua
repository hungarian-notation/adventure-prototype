local Vector = require 'eonz.vector'
local ECS = require 'eonz.ecs'

--

local entities

local hurtFlash = 0

local keys = {
  up    = 'w',
  left  = 'a',
  down  = 's',
  right = 'd'
}

--

local function Enemy(params) 
  params = (type(params) == 'table' and params) or {}
  
  return {
    mass = 1 or params.mass,
    health = 3 or params.health
  }
end

local spawnEnemy -- forward declaration of function that spawns enemies randomly on the screen

local function PlayerController()
  local PLAYER_ACCEL = 1000
  local PLAYER_DAMP = 0.01
  
  local SWORD_SWING_TIME = 0.05
  local SWORD_HOLD_TIME = 0.4
  
  local SWORD_ANGLE = math.pi * 0.8
  local SWORD_RADIUS = 48
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
          hurtFlash = 0.2
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

local function ChaseController()
  local CHASE_ACCEL = 100
  local CHASE_DAMP = 0.1
  local CHASE_IMPULSE = 500
  
  return function(e, dt, ecs)
    local target = nil
    
    for id, entity in ecs:each() do 
      if entity.isPlayer then target = entity ; break end 
    end
    
    -- impulse physics
    
    for id, entity in ecs:each() do
      if entity.radius and entity.pos then
        if entity ~= e and (entity.pos - e.pos):length() < entity.radius + e.radius then
          local dir = (e.pos - entity.pos):normal(true)
          e.vel = ((e.vel or Vector.zero()) + (dir * CHASE_IMPULSE * dt))
        end
      end
    end
    
    if target then
      local heading = (target.pos - e.pos):normal(true)
      e.vel = ((e.vel or Vector.zero()) + (heading * CHASE_ACCEL * dt)) * CHASE_DAMP ^ dt 
      e.pos = e.pos + e.vel * dt
    end
  end
end

local function CircleDrawable(radius, rgba)
  return function(e)
    love.graphics.setColor(rgba or e.color or {255, 255, 255})
    love.graphics.circle('fill', 0, 0, radius or e.radius, 32)
  end
end

local function PlayerDrawable(avatar)
  
  local SWORD_BLADE_SIZE = 0.1
  
  return function(e)
    if e.sword then
      local sword = e.sword
      
      local angle = sword.dir:angle()
      local phase = math.min(1, sword.time / sword.holdTime)
      
      -- These control the rate at which the swing and fade
      -- animations occur relative to the total duration
      -- of the sword animation.
      
      local swingPhase = math.min(1, phase * (sword.holdTime / sword.swingTime))
      local fadePhase = (1 - math.min(1, phase * 2)) ^ 2
      
      -- Determine the angles between which to draw the
      -- sword slash at the current point in the sword
      -- animation.
      
      local from = angle - (sword.theta / 2 * sword.swing)
      local to = from + (sword.theta * swingPhase * sword.swing)
      
      love.graphics.setStencilTest('equal', 0)
      love.graphics.stencil(function() love.graphics.circle('fill', 0, 0, sword.radius.inner) end)
      
      -- Draw the 'swoosh' of the sword.
      
      love.graphics.setColor({ sword.color[1], sword.color[2], sword.color[3], 0xFF * fadePhase })
      love.graphics.arc('fill', 0, 0, sword.radius.outer, from, to, 10)
      
      love.graphics.setColor(sword.color)
      love.graphics.arc('fill', 0, 0, sword.radius.outer, to - SWORD_BLADE_SIZE, to + SWORD_BLADE_SIZE, 1)
      
      love.graphics.setStencilTest()
    end
  
    avatar(e)
  end
end

spawnEnemy = function(ecs) 
  local width, height = love.window.getMode()
  
  local offVert = math.random() > 0.5
  
  local x, y
  
  if offVert then
    x = math.random() * width
    y = (math.random() > 0.5) and -10 or height + 10
  else
    x = (math.random() > 0.5) and -10 or width + 10
    y = math.random() * height
  end
  
  ecs:create {
    radius      = 8,
    
    drawable    = CircleDrawable(),
    color       = {0x88, 0x99, 0x22},
    
    pos         = Vector(x, y),
    controller  = ChaseController(),
    enemy       = Enemy()
  }
end

function love.load(args)
  entities = ECS.new()
  
  
  for i = 1, 20 do
    spawnEnemy(entities)
  end
  
  entities:create {
    radius      = 16,
    isPlayer    = true,
    
    drawable    = PlayerDrawable(CircleDrawable()),
    pos         = Vector(200, 200),
    color       = {255, 255, 255},
    controller  = PlayerController()
  }
end

function love.update(dt)
  if hurtFlash > 0 then
    hurtFlash = hurtFlash - dt
  end
  
  for id, entity in entities:each() do
    if entity.controller then entity:controller(dt, entities) end
  end
end

function love.draw()
  love.graphics.clear(0xFF * math.min(1, math.max(hurtFlash, 0)), 0, 0)
  
  for id, entity in entities:each() do
    if entity.drawable then
      love.graphics.origin()
      
      if entity.pos then 
        love.graphics.translate(entity.pos.x, entity.pos.y)
      end
      
      entity:drawable(entities)
    end
  end
end