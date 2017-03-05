local event_names = {} ; local function declare_event( name ) event_names[name] = name end

declare_event 'update'
declare_event 'draw'
declare_event 'attack'
declare_event 'death'
declare_event 'injured'

setmetatable(event_names, {
  __index = function(table, key) error("no such event: ".. tostring(key)) end  
})

return eonz.table.seal(event_names)