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

function add(i,...) return i.is.add(i,...) end

function Some:adds(t) for _,x in pairs(t) do self:add(x) end; return self end

function Some:add(x)
  r = math.random
  if #self.has < self.max then pos = 1+#self.has 
  elseif r() < self.max/self.n then pos = 1+(r()*#self.has)//1 end 
  if pos then self.bad=true; self.has[pos]=x end end

function Some:all()  
  if self.bad then table.sort(self.has) end; self.bad=false; return self.has end

-- ### Col():Col

-- Abstract class for columns. Allows one or more items to be added via `add` or `adds`.
local Col=klass("Col",Obj)

function Col:new(c,s) 
  s = s or "" 
  return isa(self, Obj:new(),{at= c or 1, name=s, n=0,
                              w=(s:find"+" and 1 or (s:find"-" and -1 or 0))}) end 

function Col:adds(t) for _,x in pairs(t) do self:add(x) end; return self end

function Col:add(x) 
  if x~="?" then self.n=1+self.n; self:add1(x) end; return self end

--- ### Num(?n:int, ?s:str):Num

-- Counter for numbers at column `n`, named `s`.    
-- **:add(x)** updates the symbol counts.   
-- **:mid()** returns central tendency.     
-- **:var()** returns standard deviation.
local Num=klass("Num",Col)

function Num:new(n,s) 
  return isa(self, Col:new(n,s),{some=Some:new(),mu=0,m2=0,sd=0,lo=1E32,hi=-1E32}) end

function Num:mid() return self.mu end

function Num:var() return self.sd end

function Num:add1(x,    d)
  self.some:add(x)
  d       = x - self.mu
  self.mu = self.mu + d/self.n
  self.m2 = self.m2 + d*(x - self.mu)
  self.sd = (self.m2<0 or self.n<2) and 0 or (self.m2/(self.n-1))^0.5
  if x < self.lo then self.lo = x end
  if x > self.hi then self.hi = x end end

-- ### Sym(?n:int, ?s:str):Sym

-- Counter for symbols at column `n`, named `s`.   
-- **:add(x)** updates the symbol counts.   
-- **:mid()** returns central tendency.     
-- **:var()** returns entropy.
local Sym=klass("Sym",Col)
function Sym:new(n,s) 
  return isa(self,Col:new(n,s),{most=0,mode="?",has={}}) end 

function Sym:mid() return self.mode end

function Sym:var(  e) 
  e=0; for _,v in pairs(self.has) do e=e - v/self.n * math.log(v/self.n,2) end
  return e end

function Sym:add1(x,    d)
  self.has[x] = 1 + (self.has[x] or 0)
  if self.has[x] > self. most then self.most,self.mode=self.has[x], x end end

-- ---------------------------------------
-- ## Start up
n=Some:new():adds{"a","a","a","b","b"}
s=Sym:new(22,"fred"):adds{"a","a","a","b","b"}
c=Num:new(1,"asdas-"):adds{22,32,41,100,1}
--c=Num(1,"asdas-"):add(22) --,32,41,100,1}
print(c)
print(n)
print(s)
print(Some:new(22,"as"))
print(show{200,10,10000})
