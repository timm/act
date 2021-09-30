-- **showr(t:tbl) :str**     
-- Return table as string.
function show(t,     u,mt,pre)
  if   #t>0
  then u={}; for _,v in pairs(t) do u[1+#u]=tostring(v) end
  else ks={}; for k,_ in pairs(t) do if k:sub(1,1)~="_" then ks[1+#ks]=k end end
       table.sort(ks)
       u={}; for _,k in pairs(ks) do u[1+#u]= k.."="..tostring(t[k]) end end
  pre = (getmetatable(t) or {})._name or ""
  return pre.. "("..table.concat(u,", ")..")" end

-- ## OO Stuff

-- **klass(name:str):tbl**   
-- Create a constructor `klass()` (and store a print `name`).
function klass(name,   k) 
  k={}; k._name=name
  return setmetatable(k,{__call=function(k,...) return k:new(...) end}) end
-- **isa(klass:tbl, ?new:tbl, ?also:tbl):tbl**    
-- Delegate calls to `new` to `klass`. If `also` exists, add those slots.
function isa(self,    new,also, super)
  new, also = new or {}, also or {}
  super = getmetatable(new)
  if super then setmetatable(self, super) end
  self.__index, self.__tostring = self,show
  for k,v in pairs(also) do new[k]=v end
  return setmetatable(new, self) end

-- ## obj()

-- Base class.
local obj=klass"obj"
function obj:new() return isa(obj) end

-- **some:new(?max=256):some**   
-- Reservoir sampler (of upper size of `max`).
-- If we fill up, delete anything at random.
-- If we ask for `all` those values, then ensure them come back sorted.
local some=klass"some"
function some:new(max) 
  return isa(self,obj:new(),{max=max or 256,bad=false,has={}}) end
function some:add(x)
  r = math.random
  if #self.has < self.max then pos = 1+#self.has 
  elseif r() < self.max/self.n then pos = 1+(r()*#self.has)//1 end 
  if pos then self.bad=true; self.has[pos]=x end end
function some:all()  
  if self.bad then table.sort(self.has) end; self.bad=false; return self.has end

-- ## col():col

-- Abstract class for columns. Allows one or more items to be added via `add` or `adds`.
local col=klass"col"
function col:new(c,s) 
  s = s or "" 
  return isa(self, obj:new(),{at=c or 1, name=s, n=0,
                              w=s:find"+" and 1 or (s:find"-" and -1 or 0)}) end 
function col:adds(t) 
  for _,x in pairs(t) do self:add(x) end; return self end
function col:add(x) 
  if x~="?" then self.n=1+self.n; self:add1(x) end; return self end

-- ## num(?n:int, ?s:str):num

-- Counter for numbers at column `n`, named `s`.    
-- **:add(x)** updates the symbol counts.   
-- **:mid()** returns central tendency.     
-- **:var()** returns standard deviation.
local num=klass"num"
function num:new(n,s) 
  return isa(self, col:new(n,s),
             {some=some:new(), mu=0,m2=0,sd=0,lo=1E32,hi=-1E32}) end
function num:mid() 
  return self.mu end
function num:var() 
  return self.sd end
function num:add1(x,    d)
  self.some:add(x)
  d       = x - self.mu
  self.mu = self.mu + d/self.n
  self.m2 = self.m2 + d*(x - self.mu)
  self.sd = (self.m2<0 or self.n<2) and 0 or (self.m2/(self.n-1))^0.5
  if x < self.lo then self.lo = x end
  if x > self.hi then self.hi = x end end

-- ## sym(?n:int, ?s:str):sym

-- Counter for symbols at column `n`, named `s`.   
-- **:add(x)** updates the symbol counts.   
-- **:mid()** returns central tendency.     
-- **:var()** returns entropy.
local sym=klass"sym"
function sym:new(n,s) 
  return isa(self,col:new(n,s),{most=0,mode=nil,has={}}) end 
function sym:mid() 
  return self.mode end
function sym:var(  e) 
  e=0; for _,v in pairs(self.has) do e=e - v/self.n * math.log(v/self.n,2) end
  return e end
function sym:add1(x,    d)
  self.has[x] = 1 + (self.has[x] or 0)
  if self.has[x] > self. most then self.most,self.mode=self.has[x], x end end

-- ---------------------------------------
s=sym():adds{"a","a","a","b","b"}
c=num(1,"asdas-"):adds{22,32,41,100,1}
print(c)
print(s)
print(show{200,10,10000})
