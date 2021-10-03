-- ## Classes

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

-- **Some:new(?max=256):Some**   
-- Reservoir sampler (of upper size of `max`).
-- If we fill up, delete anything at random.
-- If we ask for `all` those values, then ensure them come back sorted.
local Some=klass("Some",Obj)
function Some:new(max) 
  return isa(self,Obj:new(),{max=max or 256,bad=false,has={}}) end

-- ### Col():Col

-- Abstract class for columns. Allows one or more items to be added via `add` or `adds`.
local Col=klass("Col",Obj)
function Col:new(c,s) 
  s = s or "" 
  return isa(self, Obj:new(),{
    at=c or 1, name=s, n=0,w=(s:find"+" and 1 or (s:find"-" and -1 or 0))}) end 


