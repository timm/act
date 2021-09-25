--[[ vim: filetype=lua ts=2 sw=2 sts=2  et :
         _,---._
       /'  ,`.  `\    reason
     /'`,,'   ;   )   (c) Tim Menzies, 2021, unlicense.org
    (_   ;  ,-,---'   Bayesian semi-supervised multi-objective
     (;;,,;/--'       stakeholder-based rule generation. 
      \;;;/           In less than  250 LOC
  pb    /             
--]]
local ask
local defaults=function()  return  {
  far=    ask("-f", .9,      'where to look for far things'),
  help=   ask("-h", false,   'show  help');
  int=    ask("-i", 1E62,    'largest number'),
  loud=   ask("-l", false,   'set verbose'),
  p=      ask("-p", 2,       'distance calculation exponent'),
  samples=ask("-s", 128,     'number of neighbors to explore'),
  seed=   ask("-S", 10014,   'Seed for random numbers'),
  todo=   ask("-t", "hello", 'startup action'),
  wild=   ask("-w", false,   'run egs, no protection (wild mode)')} end

-- If there is a command-line agument  --flag,    
-- then enable a booleans  or  compile a num or return a stringa   
-- Else, just  return the  old value.
function ask(x,v,_) 
  for n,y in pairs(arg) do if x==y  then  return
    type(v)=="boolean" and true or tonumber(arg[n+1]) or arg[n+1] end end
  return v  
end

print(defaults().seed)
