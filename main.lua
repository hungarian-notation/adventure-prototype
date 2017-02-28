
local Vector = require 'eonz.vector'
local ECS = require 'eonz.ecs'

--

local entities

local keys = {
  up    = 'w',
  left  = 'a',
  down  = 's',
  right = 'd'
}

--

local PlayerDrawable

local function PlayerController()
  local PLAYER_ACCEL = 800
  local PLAYER_DAMP = 0.05
  
  local SWORD_SWING_TIME = 0.2
  local SWORD_ANGLE = math.pi * 2/3
  
  local SWORD_RADIUS = 48
  local SWORD_INNER_RADIUS = 24
  
  local nextSwingDirection = 1
  
  local function Sword(dir, color)
    
    -- alternate swing directions
    
    local swingDir = nextSwingDirection
    nextSwingDirection = nextSwingDirection * -1
    
    return {
      dir     = dir, -- normal vector that bisects the swing arc
      swing   = swingDir, -- the sign of the swing motion
      time    = SWORD_SWING_TIME, -- the remaining duration of the swing in seconds
      maxTime = SWORD_SWING_TIME, -- the total duration of the swing
      theta   = SWORD_ANGLE, -- the total angle covered by the swing
      radius  = { outer=SWORD_RADIUS, inner=SWORD_INNER_RADIUS }, -- the size of the swing in pixels
      color   = color or {255, 0, 0}
    }
    
  end
  
  local function attack(e, dt)
    local dir = (Vector.new(love.mouse.getPosition()) - e.pos):normalized()
    e.sword = Sword(dir)
  end
  
  return function(e, dt)
    
    if e.sword then
      e.vel = Vector.zero()
      
      e.sword.time = e.sword.time - dt
      if e.sword.time <= 0 then
        e.sword = nil
      end
    end
    
    -- Sword Control
    
    if not e.sword and love.mouse.isDown(1) then
      attack(e, dt)
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
  local CHASE_ACCEL = 200
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
          local dir = (e.pos - entity.pos):normalized(true)
          e.vel = ((e.vel or Vector.zero()) + (dir * CHASE_IMPULSE * dt))
        end
      end
    end
    
    if target then
      local heading = (target.pos - e.pos):normalized(true)
      e.vel = ((e.vel or Vector.zero()) + (heading * CHASE_ACCEL * dt)) * CHASE_DAMP ^ dt 
      e.pos = e.pos + e.vel * dt
    end
  end
end

local function CircleDrawable(radius, rgba)
  return function(e)
    love.graphics.setColor(rgba or e.color or {255, 255, 255})
    love.graphics.circle('fill', 0, 0, radius, 32)
  end
end

PlayerDrawable = function(avatar)
  
  local SWORD_BLADE_SIZE = 0.1
  
  return function(e)
    if e.sword then
      local sword = e.sword
      
      local angle = sword.dir:getAngle()
      local phase = 1 - sword.time / sword.maxTime
      
      -- These control the rate at which the swing and fade
      -- animations occur relative to the total duration
      -- of the sword animation.
      
      local swingPhase = math.min(1, phase * 5)
      local fadePhase = 1 - math.min(1, phase * 1)
      
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

function love.load(args)
  entities = ECS.new()
  
  local width, height = love.window.getMode()
  
  for i = 1, 20 do
    entities:create {
      radius      = 8,
      
      drawable    = CircleDrawable(8),
      color       = {0x88, 0x99, 0x22},
    
      pos         = Vector(math.random() * width, math.random() * height),
      controller  = ChaseController()
    }
  end
  
  entities:create {
    isPlayer    = true,
    
    drawable    = PlayerDrawable(CircleDrawable(16)),
    pos         = Vector(200, 200),
    color       = {255, 255, 255},
    controller  = PlayerController()
  }
end

function love.update(dt)
  for id, entity in entities:each() do
    if entity.controller then entity:controller(dt, entities) end
  end
end

function love.draw()
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