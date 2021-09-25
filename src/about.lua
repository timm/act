-- vim: filetype=lua ts=3 sw=3 sts=3 et :

local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
local ask, defaults
local banner=[[

   |\_        reason
   /  .\_     (c) Tim Menzies, 2021, unlicense.org
  |   ___)    
  |    \      Bayesian sem-supervised multi-objective
  |  =  |     stakeholder-based rule generation
  /_____\     (in less  than 250 LOC)
 [_______] ]]

function defaults()  return  {
   far=    ask("-f", .9,      'where to look for far things'),
   help=   ask("-h", false,   'show  help');
   int=    ask("-i", 1E62,    'largest number'),
   loud=   ask("-l", false,   'set verbose'),
   p=      ask("-p", 2,       'distance calculation exponent'),
   samples=ask("-s", 128,     'number of neighbors to explore'),
   seed=   ask("-S", 10014,   'Seed for random numbers'),
   todo=   ask("-t", "hello", 'startup action'),
   wild=   ask("-w", false,   'run egs, no protection (wild mode)')} end

-- If there is a command-line argument  --`flag`,  then enable a booleans  
-- or  compile a num or return a string. Else, just  return `old` value.
function ask(flag,old,_) 
   for n,x in pairs(arg) do if x==flag then return
      type(old)=="boolean" and true or tonumber(arg[n+1]) or arg[n+1] end end
   return old end

local Eg={}
Eg["hello"]=function() print(banner) end

if debug.getinfo(2) then Eg[defaults().todo]() end
for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
