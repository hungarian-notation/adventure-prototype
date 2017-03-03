
return function(params) 
  params = (type(params) == 'table' and params) or {}
  
  return {
    mass = params.mass or 1,
    health = params.health or 3,
  }
end
