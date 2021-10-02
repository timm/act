-- ## Config Options

local function ask(flag,b4,_) 
  for n,x in pairs(arg) do if x==flag then return
    type(b4)=="boolean" and true or tonumber(arg[n+1]) or arg[n+1] end end
  return b4 end

return function() return {
  seed= ask( "-S", 10014,   'Seed for random numbers'),
  far=  ask( "-f", .9,      'where to look for far things'),
  help= ask( "-h", false,   'show  help');
  loud= ask( "-l", false,   'set verbose'),
  p=    ask( "-p", 2,       'distance calculation exponent'),
  some= ask( "-s", 128,     'number of neighbors to explore'),
  todo= ask( "-t", "hello", 'startup action'),
  wild= ask( "-w", false,   'run egs, no protection (wild mode)')
} end
