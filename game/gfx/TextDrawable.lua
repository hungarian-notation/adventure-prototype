local function TextDrawable(e, font, string, color) 
  local text = love.graphics.newText(font, string)
  
  return {
    on_draw = function()
      color = color or e.color or {0xFF, 0xFF, 0xFF}
      
      love.graphics.setColor(color[1], color[2], color[3], 0xFF * math.min(1, e.time))
      love.graphics.draw(text)
    end
  }
end

return eonz.entities.Injector(TextDrawable)