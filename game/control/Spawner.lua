local challenges = game.challenges

-- local ADVANCE_TO = 99

local function Spawner(entity, screen)
  local system = entity:system()
  
  local self = { 
    time = 0, 
    kills = 0, 
    nextChallenge = nil, 
    challenge = nil, 
    roster = nil,
    population = 0
  }
  
  local function findChallenge(kills)
    for id, challenge in ipairs(challenges) do
      if not challenge.completed and challenge.kills <= kills then
        return challenge
      end
    end
  end
  
  function self:getTargetCount()
  	return self.population
  end
  
  function self:getEnemyCount()
    local count = 0
    
    for id, entity in system:each() do
      if entity.enemy then count = count + 1 end
    end
    
    return count
  end
  
  function self:DeathTracker()
    local spawner = self
    local tracker = {}
    
    function tracker:on_death()
    	spawner.kills = spawner.kills + 1
      print(tostring(spawner.kills) .. " Kills!")
    end
    
    return tracker
  end
  
  function self:startChallenge()
  	print("STARTING CHALLENGE")
    
    screen.color = {0x33, 0x33, 0x22}
    
    self.challenge = self.nextChallenge
    self.nextChallenge = nil
    
    for i, spawn in ipairs(self.challenge.spawn) do
    	for i = 1, spawn.count do
        
        local spawned = game.enemies.Slime(spawn.slime)
        local pos, dir = game.enemies.getRandomPosition()
        spawned.pos = pos
        spawned.vel = dir * 1000
        spawned = system:create(spawned) 
        spawned:add(self:DeathTracker())
        
      end
    end
  end
  
  function self:completeChallenge(challenge)
    screen.color = {0x22, 0x33, 0x44}
    
    local oldPopulation = self.population
    local oldRoster = self.roster
    self.population = challenge.population or oldPopulation
    self.roster = challenge.roster or oldRoster
    challenge.completed = true
  end
  
  function self:on_update(dt)
    self.time = self.time + dt
    
    if not self.nextChallenge then
      local challenge = findChallenge(self.kills)
      if self.challenge ~= challenge then
        self.nextChallenge = challenge
      end
    end
    
    if self.challenge then
      if self:getEnemyCount() == 0 then
        self:completeChallenge(self.challenge)
        self.challenge = nil
      end
    elseif self.nextChallenge then
      if self:getEnemyCount() == 0 then
        self:startChallenge()
      end
    else
      local toSpawn = self:getTargetCount() - self:getEnemyCount()
      
      for i = 1, toSpawn do
        local entity = game.enemies.spawn(system, self.roster)
        entity:add(self:DeathTracker())
      end
    end
  end
  
  function self:on_draw()
    love.graphics.origin()
    
    local width, height = love.window.getMode()
    
    local timerText = love.graphics.newText(game.res.fonts.debug_text, string.format("%02d:%02d", self.time / 60, self.time % 60))
    local killText = love.graphics.newText(game.res.fonts.debug_text, self.challenge and self.challenge.title or string.format("%d Kills", self.kills))
    
    love.graphics.setColor(game.res.colors.debug_text)
    love.graphics.draw(timerText, 20, 20)
    love.graphics.draw(killText, width / 2 - killText:getWidth() / 2, 20)
  end

  for i = 1, ADVANCE_TO or 0 do
    self.kills = i
    
    local challenge = findChallenge(i)
    if challenge then
      self:completeChallenge(challenge)
    end
  end
  
  return self
end

return eonz.entities.Injector(Spawner)