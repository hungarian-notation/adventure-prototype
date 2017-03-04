require 'eonz' { global_vector = true, global_namespace = true, debug_messages = true }
  game = lib.game

--

local cursors = {}
local fonts = {}
local entities
local screenEffects = { hurtFlash=0 }

local keys = {
  up    = 'w',
  left  = 'a',
  down  = 's',
  right = 'd'
}

--

local function spawnEnemy(_entities) 
  local width, height = love.window.getMode()
  local x, y
  
  if math.random() > 0.5 then
    x = math.random() * width
    y = (math.random() > 0.5) and -10 or height + 10
  else
    x = (math.random() > 0.5) and -10 or width + 10
    y = math.random() * height
  end
  
  _entities:create { -- Create Enemy Entity
    radius      = 10,
    drawable    = game.gfx.CircleDrawable(),
    color       = {0x88, 0x99, 0x22},
    pos         = vector(x, y),
    controller  = game.control.TacticsController { 
      tactic = game.strategy.ZombieStrat()
    },
    enemy       = game.components.EnemyTag()
  }
end

function love.keypressed(key, code, repeated)
  if key == 'escape' then
    love.event.quit()
  end
end

local function genCursor() 
  local csz = 16
  local mx = csz / 2
  local my = csz / 2
  local canvas = love.graphics.newCanvas(csz, csz)
  
  love.graphics.setCanvas(canvas)  
  love.graphics.setColor{0xFF, 0x00, 0x00}
  love.graphics.setLineWidth(1.5)
  love.graphics.line(mx - csz / 2, my, mx + csz / 2, my)
  love.graphics.line(mx, my - csz / 2, mx, my + csz / 2)
  love.graphics.setCanvas()
  
  local cursor = love.mouse.newCursor(canvas:newImageData(), csz / 2, csz / 2)
  
  return cursor
end

function love.load(args)
  game:setVariable("res", 
    {
      fonts = lib.res.fonts,
      textures = {}, 
      sounds = {},
      colors = lib.res.colors
    }) -- resource table
  
  cursors = { crosshair = genCursor() }
  
  love.window.setMode(1600, 900)
  love.mouse.setGrabbed(true)
  love.mouse.setCursor(cursors.crosshair)
  
  
  entities = eonz.entities.new()

  for i = 1, 20 do
    spawnEnemy(entities)
  end    
    
  entities:create { -- Player Entity
    radius      = 16,
    isPlayer    = true,
    drawable    = game.gfx.PlayerDrawable(game.gfx.CircleDrawable()),
    pos         = vector(200, 200),
    color       = {255, 255, 255},
    controller  = game.control.PlayerController(keys, spawnEnemy, screenEffects)
  }
end

function love.update(dt)
  if screenEffects.hurtFlash > 0 then
    screenEffects.hurtFlash = screenEffects.hurtFlash - dt
  end
  
  for id, entity in entities:each() do
    if entity.controller then 
      if type(entity.controller) == 'function' then
        entity:controller(dt) 
      elseif type(entity.controller) == 'table' then
        entity.controller:act(dt)
      end
    end
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
      
      entity:drawable()
    end
  end
  
  
  love.graphics.origin()
      
  local fpsText = love.graphics.newText(game.res.fonts.debug_text, "FPS: " .. love.timer.getFPS())
  
  love.graphics.setColor(game.res.colors.debug_text)
  love.graphics.draw(fpsText, 20, 20)
    
end