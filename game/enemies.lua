local enemies = {}

local EnemyComponent = game.components.EnemyComponent
local TacticsController = game.control.TacticsController
local CircleDrawable = game.gfx.CircleDrawable

local SLIME_TYPES = {
  green = {
    color   = {0x88, 0x99, 0x22}, 
    health  = 3, 
    radius  = 10,
    rarity  = 1
  },
  
  blue = {
    color   = {0x22, 0x88, 0x99}, 
    health  = 5, 
    radius  = 14, 
    rarity  = 0.1
  }
}

function enemies.RandomSlime()  
  local function selectType() 
    local types = {}
    local totalRarity = 0
    
    for k, v in pairs(SLIME_TYPES) do
      table.insert(types, { name=k, rarity=v.rarity })
      totalRarity = totalRarity + v.rarity
    end
    
    local selector = math.random() * totalRarity
    
    for i, v in ipairs(types) do
      selector = selector - v.rarity
      
      if selector <= 0 then
        return v.name
      end
    end
    
    return types[#types].name
  end
  
  return enemies.Slime(selectType())
end

function enemies.Slime(slime)
  
  slime = SLIME_TYPES[slime or 'green']
  
	return { 
    enemy   = EnemyComponent{health = slime.health},
    
    radius  = slime.radius,
    color   = slime.color,
    pos     = vector(),
    vel     = vector(),
    
    script  = slime.script,
    
    CircleDrawable(),
    TacticsController{strategy = game.strategy.SlimeStrategy}
  }
end

local function getRandomPosition()
  local width, height = love.window.getMode()
  local x, y
  
  if math.random() > 0.5 then
    x = math.random() * width
    y = (math.random() > 0.5) and -10 or height + 10
  else
    x = (math.random() > 0.5) and -10 or width + 10
    y = math.random() * height
  end
  
  return vector(x, y)
end

function enemies.spawn(system) 
  local function on_death() 
    enemies.spawn(system)
  end
  
  local enemy = enemies.RandomSlime()
  
  enemy.pos = getRandomPosition()
  table.insert(enemy, { on_death=on_death })
  
  system:create(enemy)
end

return enemies