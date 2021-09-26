-- vim: filetype=lua ts=3 sw=3 sts=3 et :

local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
local ask,defaults,obj,map,dump,fmt,col,with
local cat=table.concat
local Eg,Num,Sym,Skip = {},{},{},{}
local banner=[[
  _________
 /_  ___   \
/@ \/@  \   \      reason (v1.0)
\__/\___/   /      (c)Tim Menzies, 2021, unlicense.org
 \_\/______/
 /     /\\\\\      Bayesian semi-supervised
|     |\\\\\\      multi-objective, stakeholder 
 \      \\\\\\\    aware rule generation 
   \______/\\\\\   (in less that 250 LOC)
    _||_||_ ]]

function defaults()  return  {
   far=  ask("-f", .9,      'where to look for far things'),
   help= ask("-h", false,   'show  help');
   int=  ask("-i", 1E62,    'largest number'),
   loud= ask("-l", false,   'set verbose'),
   p=    ask("-p", 2,       'distance calculation exponent'),
   some= ask("-s", 128,     'number of neighbors to explore'),
   seed= ask("-S", 10014,   'Seed for random numbers'),
   todo= ask("-t", "hello", 'startup action'),
   wild= ask("-w", false,   'run egs, no protection (wild mode)')} end

-- ----------------------------------------------
-- ## Classes

### Create

function  Some:new(some)
   return  obj(self,"Some",{max=i(some  or 255)})
function Sym:new(at, name) -- for symbolic columns
   return obj(self,"Sym", with(_col(at,txt), {has={}, mode="", most=0})) end

function Num:new(at,txt,the)  -- for  numeric  columns
   return obj(self,"Num",
      with(_col(at,txt), 
          {mu=0, lo= inf, hi= -inf, some=some or Some(the.some)})) end 

function col(at,txt)  -- common slots
   at, txt = at or 0, txt or ""
   w = "-"==txt:sub(#s,#s) and -1 or 1
   return {at=at, txt=txt, n=0, w=w} end

### update
function add(i,x) 
   if type(x)=="table" 
   then for _,y in pairs(i) do add(i,y) end 
   elseif x !="?" then
      i.n += 1
      i:add(x) end end

function Num:add(x)
   
-- ----------------------------------------------
-- ## Misc

-- **ask(flag: str, old: any, _:any) : any**   
-- If there is a command-line argument  --`flag`,  then enable a booleans
-- or  compile a num or return a string. Else, just  return `old` value.
function ask(flag,old,_) 
   for n,x in pairs(arg) do if x==flag then return
      type(old)=="boolean" and true or tonumber(arg[n+1]) or arg[n+1] end end
   return old end

-- ### Meta

-- **map(t :table, ?f :function): table**   
-- map function `f` over all items in `t`.
function map(t,f,     b)
  b, f = {}, f or function(z) return z end
  for i,v in pairs(t or {}) do b[i] = f(v) end 
  return b end 

-- **obj(self:table, name:str, new:t) : table**     
-- Return a new object of type `self` with print `name` with fields `t`.
function obj(self, name, new)
  self.__tostring = dump 
  self.__index    = self
  self._name      = name
  return setmetatable(new or {}, self) end

-- **with(t: table, t2: table): table**
-- add the `t2` key/values to `t1`
function with(t1,t2) for k,v in pairs(t2) do t1[k]=v end end

-- ### Strings

-- **dump(t:table): string**    
-- Convert table to string.
function dump(t) 
   local function kv(a)
      for k,v in pairs(t) do a[1+#a] = fmt("%s=%s", k, tostring(v)) end 
      return a end
   return #t>0 and '{'..cat(map(t,tostring),", ")..'}' or dump(kv({})) end 

-- **fmt(fmt :string, ?arg1 :any, ?arg2 :any, ...)**  
-- format a string
function fmt( ...) return string.format(...) end

-- ----------------------------------------------
-- ## Start up

-- ### Tests
local Eg={}
Eg["hello"]=function() print(banner) end
Eg["dump"]= function() print(dump{a="aaa",b="bbb"}) end

-- ### Main
if debug.getinfo(2) then Eg[defaults().todo]() end
for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
