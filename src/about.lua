-- ## Config Options

local function got(flag,b4)
  for n,x in pairs(arg) do if x==flag then return tell(n,b4) end
    return type(b4)=="boolean" and true or tonumber(arg[n+1]) or arg[n+1] end end

local function get(flag,b4,_) return got(flag,b4) or b4 end 

return function() return {
  seed=   get( "-S", 10014,   'Seed for random numbers'),
  help=   get( "-h", false,   'show  help'),
  loud=   get( "-l", false,   'set verbose'),
  dist= {
    far=  get( "-f", .9,      'where to look for far things'),
    p=    get( "-p", 2,       'distance calculation exponent'),
    some= get( "-s", 128,     'number of neighbors to explore')},
  eg= {
    todo= get( "-t", "hello", 'startup action'),
    wild= get( "-w", false,   'run egs, no protection (wild mode)')}
} end
