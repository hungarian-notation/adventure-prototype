local enemies = {}

local EnemyComponent = game.components.EnemyComponent
local TacticsController = game.control.TacticsController
local CircleDrawable = game.gfx.CircleDrawable

local function split(slime, min, max)
  return function(entity)
    local system = entity:system()
    
    return {
      on_death = function() 
        
        local count = min + (max and math.floor((max - min) * math.random() + 1) or 0)
        
        game.res.sounds.slime_call:play()
        
        for i = 1, count do
          local slime = enemies.Slime(slime)
          
          local offset = vector.polar(math.pi * 2 / count * i, entity.radius / 2)
          
          slime.pos = entity.pos + offset
          slime.vel = offset:normal() * 50 + entity.vel * 3
          
          system:create(slime)
          
        end
      end
    }
  end
end


local SLIME_TYPES = {
  green = {
    color   = {0xAA, 0xCC, 0x44}, 
    health  = 2, 
    radius  = 10,
    agility = 1,
    flicker = 0,
    
    rarity  = 1
  },
  
  red = {
    color   = {0x99, 0x22, 0x22}, 
    health  = 2, 
    radius  = 8,
    agility = 3,
    
    rarity  = 0.1
  },
  
  blue = {
    color   = {0x22, 0x88, 0x99}, 
    health  = 4, 
    radius  = 14, 
    agility = 1.2,
    
    rarity  = 0.1
  },
  
  big_green = {
    color   = {0x88, 0x99, 0x22}, 
    health  = 8, 
    radius  = 20,
    agility = 0.6,
    
    rarity  = 0.1,
    
    script = split('green', 2, 5)
  },
  
  huge_green = {
    color   = {0x66, 0x77, 0x11}, 
    health  = 12, 
    radius  = 26,
    agility = 0.3,
    
    rarity  = 0.05,
    
    script = split('big_green', 2, 3)
  },
  
  pinky = {
    color   = {0xFF, 0xAA, 0xAA}, 
    health  = 10, 
    radius  = 5,
    agility = 5,
    
    rarity  = 0.05
  },
  
  clusterfuck = {
    color   = {0xFF, 0x77, 0xFF}, 
    health  = 8, 
    radius  = 26,
    agility = 4,
    
    rarity  = 0.005,
    
    script = split('pinky', 3, 5)
  },
  
  spy = {
    color   = {0xCC, 0xCC, 0x44}, 
    health  = 1, 
    radius  = 10,
    agility = 1,
    
    rarity = 0.005,
    
    script = split('pinky', 1, 2)
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
    enemy   = EnemyComponent{health = slime.health, flicker = slime.flicker},
    
    radius  = slime.radius,
    color   = slime.color,
    pos     = vector(),
    vel     = vector(),
    
    script  = slime.script and eonz.entities.InjectorClosure(slime.script),
    
    CircleDrawable(),
    TacticsController{ strategy = game.strategy.SlimeStrategy{ agility = slime.agility } }
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

function enemies.random()
  local enemy = enemies.RandomSlime()
  enemy.pos = getRandomPosition()
  return enemy
end

function enemies.spawn(system) 
  return system:create(enemies.random())
end

return enemies