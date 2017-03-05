require 'eonz' { global_vector = true, global_namespace = true, debug_messages = true }

-- Any time we declare a true global in this codebase we use the _G table like so.
_G['game'] = lib.game 
-- Any other pollution of the global scope is accidental and a bug.

--
--
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
      sounds = lib.res.sounds,
      colors = lib.res.colors
    }) -- resource table
  
  cursors = { crosshair = genCursor() }
  
  love.window.setMode(1600, 900)
  love.mouse.setGrabbed(true)
  love.mouse.setCursor(cursors.crosshair)
  
  entities = eonz.entities.new()

  for i = 1, 10 do
    game.enemies.spawn(entities)
  end    
    
  entities:create { -- Player Entity
    radius      = 16,
    isPlayer    = true,
    drawable    = game.gfx.PlayerDrawable(game.gfx.CircleDrawable()),
    pos         = vector(200, 200),
    vel         = vector.zero(),
    color       = {255, 255, 255},
    controller  = game.control.PlayerController(keys, screenEffects)
  }
end

function love.update(dt)
  if screenEffects.hurtFlash > 0 then
    screenEffects.hurtFlash = screenEffects.hurtFlash - dt
  end
  
  for id, entity in entities:each() do
    eonz.event.dispatch(entity, game.event.update, dt) 
  end
end

function love.draw()
  love.graphics.clear(0xFF * math.min(1, math.max(screenEffects.hurtFlash, 0)), 0, 0)
  
  for id, entity in entities:each() do
      love.graphics.origin()
      
      if entity.pos then 
        love.graphics.translate(entity.pos.x, entity.pos.y)
      end
      
      eonz.event.dispatch(entity, game.event.draw) 
  end
  
  love.graphics.origin()
      
  local fpsText = love.graphics.newText(game.res.fonts.debug_text, "FPS: " .. love.timer.getFPS())
  
  love.graphics.setColor(game.res.colors.debug_text)
  love.graphics.draw(fpsText, 20, 20)
end