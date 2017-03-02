local Vector = require 'eonz.Vector'

local util = {}

function util.newStatus(pos, time, drawable) 
  return {
    pos=pos,
    time=time,
    drawable=drawable,
    controller=require('game.behavior.StatusController')()
  }
end

function util.newTextStatus(pos, time, font, string, color)
  return util.newStatus(pos, time, require('game.graphics.TextDrawable')(font, string, color))
end

function util.newDamageNumber(pos, font, damage)
  return util.newTextStatus(pos, 1, font, damage, {0xFF, 0x33, 0x33})
end

return util