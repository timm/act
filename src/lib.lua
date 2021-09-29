local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
local order,fmt,str,obj, csv
local rand={}

function with(t1,t2) for k,v in pairs(t2) do t1[k]=v end; return t1; end 

function order(t) table.sort(t); return t  end

function fmt(...) return string.format(...) end

function str(t,     u,ks)
  ks={}; for k,v in pairs(t) do ks[1+#ks] = k end
  u={};  for _,k in pairs(order(ks)) do 
           u[1+#u]= #t>0 and tostring(t[k]) or fmt("%s=%s",k,t[k]) end
  return "{"..table.concat(u,", ").."}" end

function obj(self,    new,super)
  new = new or {}
  super = getmetatable(new)
  if super then setmetatable(self, super) end
  self.__tostring, self.__index=str,self
  return setmetatable(new or {}, self) end

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

local function top(t,n,     u)
  u={}; for i=1,n do u[i]=t[i] end
  return u end

local function shuffle(t,the,     j)
  for i = #t, 2, -1 do
    j = the.rand:int(1,i)
    t[i], t[j] = t[j], t[i] end
  return t end

function rand:new(seed)   return obj(rand,{seed=seed or 10014})  end
function rand:int(lo,hi); return math.floor(0.5 + self:next(lo,hi)) end
function rand:next(lo,hi) 
  lo, hi = lo or 0, hi or 1
  self.seed = (16807 * self.seed) % 2147483647 
  return lo + (hi-lo) * self.seed / 2147483647 end 

for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
return {shuffle=shuffle, order=order, fmt=fmt, str=str, obj=obj, csv=csv,rand=rand}
