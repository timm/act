-- # Misc lib stuff

local about=require"about"

-- ## Random Stuff

local Rand,Seed={},10014

-- **srand(seed:int)**    
-- Set random  number seed.
local function srand(seed) Seed=seed or Seed end
--  **rand(?lo:num=0, ?hi:num=1):num**    
-- Return a random integer from `lo` to ` hi`.
local function rand(lo,hi) 
  lo, hi = lo or 0, hi or 1
  Seed = (16807 * Seed) % 2147483647 
  return lo + (hi-lo) * Seed / 2147483647 end 
--  **randi(lo:num, hi:num):num**  
-- Return a random integer from `lo` to ` hi`.
local function randi(lo,hi); return math.floor(0.5 + rand(lo,hi)) end

--  ## String Stuff

-- Formatting strings
local function fmt(...) return string.format(...) end

-- **showr(t:tbl) :str**     
-- Return table as string. Print table in sorted keys
-- order. For simple arrays (with contiguous numeric keys). don't
-- show the keys.
local function show(t,     s,u,mt,pre,ks)
  u,ks = {},{}
  if   #t>0
  then for k,_ in pairs(t) do ks[1+ks] = k end
  else for k,_ in pairs(t) do if k:sub(1,1)~="_" then ks[1+#ks]=k end end
       table.sort(ks)
  end
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

-- Combining two tables
local function with(t,also) for k,v in pairs(also) do t[k]=v end return t end
-- Sorting lists.
local function order(t) table.sort(t); return t  end
-- Randomizing order or list
local function shuffle(t,the,     j)
  for i = #t, 2, -1 do
    j = randi(1,i)
    t[i], t[j] = t[j], t[i] end
  return t end
-- First few items in a list
local function top(t,n,     u)
  u={}; for i=1,n do u[i]=t[i] end
  return u end

-- ## File Stuff

-- Reading csv files (each line read as one table)/
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


-- -------
-- Returns:
return {
   about=about,  
   color=color,
   fmt=fmt, 
   isa=isa, 
   klass=klass, 
   order=order, 
   rand=rand,
   randi=randi, 
   show=show, 
   shuffle=shuffle, 
   srand=srand, 
   top=top,
   with=with
 }
