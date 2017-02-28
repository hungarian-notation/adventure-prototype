local vector = require 'eonz.vector'

local style = {
  cursor_size = 10;
}

local cursor = vector.new(0, 0)
local player = nil

local swordTime = 0.333
local swordAngle = math.pi * 2/3

local swingDir = 1
local sword = nil

function love.load()
  love.mouse.setVisible(false)
  local width, height = love.window.getMode()
  player = vector.new(width / 2, height / 2)
end

local function updateCursor()
    local x, y = love.mouse.getPosition()
    cursor.x = x
    cursor.y = y
end

local function attack() 
  if not sword then
    local offset = (cursor - player)
    local dir = offset:normalized()
    
    sword = { 
      dir=dir, 
      swing=swingDir, 
      time=swordTime, 
      theta=swordAngle, 
      radius=48, 
      innerRadius=24 
    }
    
    swingDir = swingDir * -1
  end
end

function love.update(dt)
  if sword then
    sword.time = sword.time - dt
    if sword.time <= 0 then
      sword = nil
    end
  end
  
  updateCursor()
  
  if love.mouse.isDown(1) then
    attack()
  end
end

function love.draw()
  updateCursor()
  
  local width, height = love.window.getMode()
  
  if sword then    
    local angle = sword.dir:getAngle()
    local phase = 1 - sword.time / swordTime
    
    local swingPhase = math.min(1, phase * 5)
    local fadePhase = 1-math.min(1, phase * 1)
    
    local from  = angle - (sword.theta / 2 * sword.swing)
    local to = from + (sword.theta * swingPhase * sword.swing)
    
    love.graphics.setStencilTest("equal", 0)
    love.graphics.stencil(function() love.graphics.circle("fill", player.x, player.y, sword.innerRadius) end)
    
    love.graphics.setColor(0xFF, 0x22, 0x22, 0xFF * fadePhase)
    love.graphics.arc("fill", player.x, player.y, sword.radius, from, to, 10)
    
    love.graphics.setColor(0xFF, 0, 0)
    love.graphics.arc("fill", player.x, player.y, sword.radius, to - 0.1, to + 0.1, 10)
    
    love.graphics.setStencilTest()
  end
  
  
  local cursor2 = (player - cursor):normalized():scale(math.min((player - cursor):length(), 128)) + cursor
  
  love.graphics.setColor(0x22, 0x22, 0x22)
  love.graphics.line(cursor2.x, cursor2.y, cursor.x, cursor.y)
  
  love.graphics.setColor(255, 255, 255)
  love.graphics.circle("fill", player.x, player.y, 16)
  love.graphics.line(cursor.x - style.cursor_size, cursor.y, cursor.x + style.cursor_size, cursor.y)
  love.graphics.line(cursor.x, cursor.y - style.cursor_size, cursor.x, cursor.y + style.cursor_size)
  
end