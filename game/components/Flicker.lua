local FLICKER_RATE = 10

local function Flicker(entity, duration, rate)
  
  local time = duration or 0.5
  local period = 1 / (rate or FLICKER_RATE)
  
  entity.visible = true
  
  local flicker = {}
  
  function flicker:onUpdate(dt)
    assert(type(dt) == 'number')
    assert(entity.flicker)
    
    entity.visible = (time % period) > (period / 2)
    
    time = time - dt
          
    if time <= 0 then
      entity.flicker = nil
      entity.visible = true
    end
  end
  
  return flicker
end

return eonz.entities.Injector(Flicker)