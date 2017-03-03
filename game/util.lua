local util = {}

function util.newStatus(pos, time, drawable) 
  return {
    pos=pos,
    time=time,
    drawable=drawable,
    controller=require('game.control.StatusController')()
  }
end

function util.newTextStatus(pos, time, font, string, color)
  return util.newStatus(pos, time, game.gfx.TextDrawable(font, string, color))
end

function util.newDamageNumber(pos, damage)
  return util.newTextStatus(pos, 1, game.res.fonts.damage_numbers, damage, {0xFF, 0x33, 0x33})
end

return util