-- vim: filetype=lua ts=3 sw=3 sts=3 et :

local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
local ask,defaults,obj,map,dump,fmt,col
local rand,randi,srand,Seed,per,add
local inf,cat = 1E32, table.concat
local Eg,Num,Sample,Skip,Sym = {},{},{},{},{}
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
   loud= ask("-l", false,   'set verbose'),
   p=    ask("-p", 2,       'distance calculation exponent'),
   some= ask("-s", 128,     'number of neighbors to explore'),
   seed= ask("-S", 10014,   'Seed for random numbers'),
   todo= ask("-t", "hello", 'startup action'),
   wild= ask("-w", false,   'run egs, no protection (wild mode)')} end

-- ----------------------------------------------
-- ## Classes

-- ### Create

-- **Num:new(?at:int, ?txt:str, ?max:int=256): Num**   
-- Summarize numerics.
function  Num:new(at,txt,max) -- for numeric columns
   txt = txt or ""
   return  obj(self,"Num",
     {n=0, at=at or 0, txt=txt, w=(txt:sub(#txt,#txt)=="-" and -1 or 1),
      lo=inf, hi=-inf, _all={}, old=false, most=n or 256}) end

-- **Skip:new(?at:int, ?txt:str, ?keep:bool=true)**   
-- Column of values  to ignore
function Skip:new(keep)
   return obj(self,"Sample", {n=0, at or 0, txt=txt or ""}) end

-- **Sample:new(?keep:bool=true)**   
-- Store rows, summarizing the columns.
function Sample:new(keep)
   return obj(self,"Sample",
      {n=0, rows={}, cols={}, x={}, y={}, keep=keep or true}) end

-- **Sym:new(?at:int, ?txt:str): Sym**   
-- Summarize symbols.
function Sym:new(at, name) -- for symbolic columns
   return obj(self,"Sym", {n=0,at=at,txt=txt,has={},mode="",most=0}) end

-- ### update

-- **add(i:column, x:any)**
-- If `x` is a table, add all its items. Else if it is not `?`, 
-- increment  the  counter and call `:add(x)`.
function add(self,x) 
   if type(x)=="table" then for _,y in pairs(self) do add(self,y) end 
   elseif x ~="?"      then self.n = self.n + 1; self:add(x)      end 
   return self end

-- **Num:add(x:any)**
function Num:add(x,  pos)
   if x > self.hi then self.hi=x end
   if x < self.lo then self.lo=x end
   if #self._all < self.most then pos= 1+#self._all end
   if rand() < self.most/self.n then pos= 1+(rand()*#self._all)//1 end
   if pos then self.old=true; self._all[pos]=x end end

-- **Sample:add(x:table)**
function Sample:add(t,     klass,num) 
   function klass(s) return s:find("+") or s:find("-") or s:find("!") end
   function num(s)   return s:sub(1,1):match("[A-Z]") end
   if   #self.cols > 0
   then for c,v in pairs(t) do self.cols[c]:add(v) end
        if   self.keep 
        then self.rows[1+#self.rows] = t end 
   else for c,s in pairs(t) do
           new = s:find("?") and Skip or (num(s) and Num or Sym)(c,s)
           self.cols[ 1 + #self.cols ] = new
           if not s:find("?") then
              what = self[klass(s) and "y" or "x"]
              what[ 1+#what ] = new end end end end

-- **Sym:add(x:any)**
function Sym:add(x)
  self.has[x] = 1 + self.has[x] 
  if self.has[x] > self.most then self.mode,self.most =x,self.has[x] end end

-- ### Query

-- **Num:all(): table**       
-- Return `_all`, sorted.
function Num:all()
   if self.old then table.sort(self._all) end
   self.old = false
   return self._all end

-- **Num:mid(): num**       
function Num:mid() return per(self:all(), .5) end
-- **Sym:mid(): any**   
function Sym:mid() return self.mode end

-- **Sym:var(): number**
function Sym:var(    e)
   e=0; for _,v in pairs(self.has) do e=e-v/self.n * math.log(v/self.n,e) end
   return e end
-- **Num:var(): number**
function Num:var() a=self:all(); return (per(a,.9) - per(a,.1))/2.56 end

-- ----------------------------------------------
-- ## Misc

-- ### Files

-- **csv(file : str) : table**    
-- Iterator. Returns rows in a csv files. Maybe convert strings to nums.
local function csv(file,      split,stream,tmp)
  stream = file and io.input(file) or io.input()
  tmp    = io.read()
  return function(       t)
    if tmp then
      t,tmp = {},tmp:gsub("[\t\r ]*",""):gsub("#.*","")
      for y in string.gmatch(tmp, "([^,]+)") do t[#t+1]=y end
      tmp = io.read()
      if  #t > 0 
      then for j,x in pairs(t) do t[j] = tonumber(x) or x end
           return t end
    else io.close(stream) end end end

-- ### Maths

-- **per(t:table, ?p:float=0.5): number**   
function per(t,p)  return t[math.min(#t, 1+(p or .5)*#t)] end

-- `srand` resets the random number seed;   
-- `randi,rand` generate random integers or floats
local Seed = 10014
function srand(s) Seed= s or 10013 end
function randi(lo,hi) return math.floor(0.5 + rand(lo,hi)) end
function rand(lo,hi,     mult,mod)
   lo,hi = lo or 0, hi or 1
   mult, mod = 16807, 2147483647
   Seed = (mult * Seed) % mod 
   return lo + (hi-lo) * Seed / mod end 

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

-- ### Misc

-- **ask(flag: str, old: any, _:any) : any**   
-- If there is a command-line argument  --`flag`,  then enable a booleans
-- or  compile a num or return a string. Else, just  return `old` value.
function ask(flag,old,_) 
   for n,x in pairs(arg) do if x==flag then return
      type(old)=="boolean" and true or tonumber(arg[n+1]) or arg[n+1] end end
   return old end

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
Eg["num"]=  function(    n)
  n=add(Num:new(), {1,2,3,4,5,6,7,8})
  print(n:var()) end

-- ### Main
if debug.getinfo(2) then Eg[defaults().todo]() end
for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
