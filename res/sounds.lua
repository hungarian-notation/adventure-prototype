local sounds = {}

local function sfx(name)
  sounds[name] = love.audio.newSource("res/sfx/"..name..".wav", 'static')
end

sfx('hit')
sfx('shoot')
sfx('slash')
sfx('kill')
sfx('slime_call')

return sounds