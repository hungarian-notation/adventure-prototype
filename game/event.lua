local event_names = {} ; local function declare_event( name ) event_names[name] = name end

declare_event 'Update'
declare_event 'Draw'
declare_event 'Attack'

declare_event 'EnemyKilled'

declare_event 'Death'
declare_event 'Injured'

setmetatable(event_names, {
  __index = function(table, key) error("no such event: ".. tostring(key)) end  
})

return eonz.table.seal(event_names)