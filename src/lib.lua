-- # Misc lib stuff

--  ## String Stuff

-- Formatting strings
local function fmt(...) return string.format(...) end

-- **showr(t:tbl) :str**     
-- Return table as string. Print table in sorted keys
-- order. For simple arrays (with contiguous numeric keys). don't
-- show the keys.
local function show(t,     u,mt,pre,ks)
  u,ks = {},{}
  for k,_ in pairs(t) do if k:sub(1,1)~="_" then ks[1+#ks]=k end end
  table.sort(ks)
  for _,k in pairs(ks) do 
    s= tostring(t[k])
    u[1+#u]= #t>0 and s or k.."="..s end 
  pre = (getmetatable(t) or {})._name or ""
  return pre.. "("..table.concat(u,", ")..")" end

-- **color(col:str, fmt:str, [arg:str]+)**     
-- Print formatted string, in  color `col`.
local function color(s,...)
  local all = {red=31, green=32, yellow=33, purple=34}
    print('\27[1m\27['.. all[s] ..'m'..fmt(...)..'\27[0m') end

-- ## OO Stuff

-- **klass(name:str):tbl**   
-- Create a constructor `klass()` (and store a print `name`).
local function klass(s,up,   k) 
  k= setmetatable({_name=is, __tostring=show}, up) 
  k.__index = k
  return k end
-- **isa(klass:tbl, ?new:tbl, ?also:tbl):tbl**    
-- Delegate calls to `new` to `klass`. If `also` exists, add those slots.
local function isa(self,    new,also, super)
  new = setmetatable(new or {},self)
  for k,v in pairs(also or {}) do new[k]=v end
  return new end
-- **Obj:new():Obt**  
local Obj=klass("Obj")
function Obj:new() return isa(Obj) end

-- ## List stuff

-- Sorting lists.
local function order(t) table.sort(t); return t  end
-- First few items ina  list
local function top(t,n,     u)
  u={}; for i=1,n do u[i]=t[i] end
  return u end
-- Randomizing order or list
local function shuffle(t,the,     j)
  for i = #t, 2, -1 do
    j = the.rand:int(1,i)
    t[i], t[j] = t[j], t[i] end
  return t end

-- ## File Stuff

-- Reading csv files (each line read as one table)/
function csv(file,      split,stream,tmp)
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

-- ## Random Stuff

local Rand,Seed={},10014

-- **srand(seed:int)**    
-- Set random  number seed.
function srand(seed) Seed=seed or Seed end
--  **randi(lo:num, hi:num):num**  
-- Return a random integer from `lo` to ` hi`.
function randi(lo,hi); return math.floor(0.5 + rand(lo,hi)) end
--  **rand(?lo:num=0, ?hi:num=1):num**    
-- Return a random integer from `lo` to ` hi`.
function rand(lo,hi) 
  lo, hi = lo or 0, hi or 1
  Seed = (16807 * Seed) % 2147483647 
  return lo + (hi-lo) * Seed / 2147483647 end 

-- -------
-- Returns:
return {show=show, klass=klass, isa=isa, order=order, top=top,
        color=color,
        shuffle=shuffle, srand=srand, randi=randi, rand=rand}
