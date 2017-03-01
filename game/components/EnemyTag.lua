
return function(params) 
  params = (type(params) == 'table' and params) or {}
  
  return {
    mass = 1 or params.mass,
    health = 3 or params.health
  }
end