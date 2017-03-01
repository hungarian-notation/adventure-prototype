local Vector = require 'eonz.Vector'
local ECS = require 'eonz.Entities'

--

local font = {}
local entities
local screenEffects = { hurtFlash=0 }

local keys = {
  up    = 'w',
  left  = 'a',
  down  = 's',
  right = 'd'
}

--

local function spawnEnemy(ecs) 
  local width, height = love.window.getMode()
  local x, y
  
  if math.random() > 0.5 then
    x = math.random() * width
    y = (math.random() > 0.5) and -10 or height + 10
  else
    x = (math.random() > 0.5) and -10 or width + 10
    y = math.random() * height
  end
  
  ecs:create { -- Create Enemy Entity
    radius      = 8,
    drawable    = require('game.graphics.CircleDrawable')(),
    color       = {0x88, 0x99, 0x22},
    pos         = Vector(x, y),
    controller  = require('game.behavior.ChaseController')(),
    enemy       = require('game.components.EnemyTag')()
  }
end

function love.load(args)
  font = {
    damageNumbers=love.graphics.newFont("res/blocktopia.ttf", 10)
  }
  
  entities = ECS.new()
  
  for i = 1, 20 do
    spawnEnemy(entities)
  end
  
  entities:create { -- Player Entity
    radius      = 16,
    isPlayer    = true,
    drawable    = require('game.graphics.PlayerDrawable')(require('game.graphics.CircleDrawable')()),
    pos         = Vector(200, 200),
    color       = {255, 255, 255},
    controller  = require('game.behavior.PlayerController')(keys, spawnEnemy, screenEffects)
  }
end

function love.update(dt)
  if screenEffects.hurtFlash > 0 then
    screenEffects.hurtFlash = screenEffects.hurtFlash - dt
  end
  
  for id, entity in entities:each() do
    if entity.controller then entity:controller(dt, entities) end
  end
end

function love.draw()
  love.graphics.clear(0xFF * math.min(1, math.max(screenEffects.hurtFlash, 0)), 0, 0)
  
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