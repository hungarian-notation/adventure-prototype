local function PlayerDrawable(e, avatar)
  avatar = e:resolve(avatar)
  
  local SWORD_BLADE_SIZE = 0.1
  
  return {
    on_draw = function()      
      if e.sword then
        local sword = e.sword
        
        local angle = sword.dir:angle()
        local phase = math.min(1, sword.time / sword.holdTime)
        
        -- These control the rate at which the swing and fade
        -- animations occur relative to the total duration
        -- of the sword animation.
        
        local swingPhase = math.min(1, phase * (sword.holdTime / sword.swingTime))
        local fadePhase = (1 - math.min(1, phase * 2)) ^ 2
        
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
      
      eonz.event.dispatch(avatar, 'draw')
    end
  }
end

return eonz.entities.Injector(PlayerDrawable)