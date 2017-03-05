local function Spawner(entity)
  local system = entity:system()
  
  local self = { time = 0, kills = 0 }
  
  function self:getTargetCount()
  	return 5 + self.time / 30
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
  
  function self:on_update(dt)
    self.time = self.time + dt
    
    local toSpawn = self:getTargetCount() - self:getEnemyCount()
    
    for i = 1, toSpawn do
      local entity = game.enemies.spawn(system)
      entity:add(self:DeathTracker())
    end
  end
  
  function self:on_draw()
    love.graphics.origin()
    
    local width, height = love.window.getMode()
    
    local timerText = love.graphics.newText(game.res.fonts.debug_text, string.format("%02d:%02d", self.time / 60, self.time % 60))
    local killText = love.graphics.newText(game.res.fonts.debug_text, string.format("%d Kills", self.kills))
    
    love.graphics.setColor(game.res.colors.debug_text)
    love.graphics.draw(timerText, 20, 20)
    love.graphics.draw(killText, width / 2 - killText:getWidth() / 2, 20)
  end

  return self
end

return eonz.entities.Injector(Spawner)