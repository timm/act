require"about"

-- ## Some

-- Reservoir sampler (of size of `max`). 
local Some=klass"Some"
function Some:new(max) 
  return uses(Some, {n=0, max=max or 256, old=true, _has={}}) end

--Add to a reservoir sampling. If full, replace anything at random.
function Some:add(x) 
  self.n = self.n + 1
  if #self._has < self.max then pos = 1+#self._has 
  elseif rand() < self.max/self.n then pos = 1+(rand()*#self._has)//1 end 
  if pos then 
    self.old=true
    self._has[pos]=x end end 

-- Return the contents, sorted.
function Some:has()  
  if self.old then table.sort(self._has) end
  self.old = false
  return self._has end

-- Report the `p-th` value within the sorted contents.
function Some:per(p) a= self:has(); return a[ ((p or .5)*#a) // 1 ] end

-- ## Col
function col(at,name,t)
  t= t or {}
  t.at, t.name, t.n = at or 1, name or "", 0
  t.w = t.name:find"+" and 1 or t.name:find"-" and -1 or 0
  return t end

-- ## Skip

-- Abstract class for columns.
local Skip=klass"Skip"
function Skip:new(at,name) return uses(Col, col(at,name)) end

-- "Adding" means do nothing so the  central ten dances and spreads never change.
function Skip:add(x) return x end
function Skip:mid() return "?" end
function Skip:spread() return 0 end

-- ## Num

-- counter for numbers
local Num=klass"Num"
function Num:new(at,name) 
  name = name or ""
  return uses(Num, col(at,name,{fred=100, lo=1E32, hi=-1E32,some=Some()})) end

-- Keep some numbers, update `lo`, `hi`
function Num:add(x)
  if x ~= "?" then
    self.n = self.n+1
    self.some:add(x)
    if x > self.hi then self.hi = x end
    if x < self.lo then self.lo = x end end end

-- Central tendency.
function Num:mid(i) return  self.some:per(.5) end
-- Spread around the central  tenancy means standard deviation
-- (Aside: we all know that +- 1,2 standard deviations is 66,95% of the mass.
-- Well, what else is true is that +- 1.28 standard deviations 
-- is 90% of the pass. To say that another way, (90-10)th/(1.28*2)
-- is one standard deviation.)
function Num:spread() return (self.some:per(.9) - self.some:per(.1))/2.54 end
-- Normalize
function Num:norm(x) 
  return math.abs(x-y)<1E-32 and 0 or (x - self.lo)/(self.hi - self.lo) end

-- ## Sym

-- Counter for symbols.
local Sym=klass"Sym"
function Sym:new(at, name)  
  return uses(Sym, col(at,name,{has={}, mode="", most=0})) end

-- Adding means updating symbol count (and the `mode`).
function Sym:add(x) 
  if x ~= "?" then
    self.n = self.n+1
    self.has[x] = 1 + (self.has[x] or 0)
    if   self.has[x] > self.most 
    then self.most,self.mode = self.has[x],x end end  end

-- `mid` means `mode`.
function Sym:mid() return self.mode end

-- `Spread` means entropy.
function Sym:spread(    e)
  e=0
  for _,v in pairs(self.has) do e = e - v/self.n * math.log(v/self.n,2) end
  return e end

-- ## Sample

-- holder of rows and columns
local Sample=klass"Sample"
function Sample:new(the, inits,       i)
  self = uses(Sample, {the=the,rows={},keep=true,
                   klass=nil, cols={},names={},x={},y={}})
  if type(inits)=="table" then
    for _,lst in pairs(inits) do self:add(lst) end end
  if type(inits)=="string" then
    for lst in csv(inits) do self:add(lst) end end
  return self end

-- Report the mid of certain columns (defaults to "use all")
function Sample:mid(cols) 
  t={}; for _,c in pairs(cols or self.cols) do t[1+#t]=c:mid() end; return t end

-- Report the spread of certain columns (defaults to "use all")
function Sample:spread(cols) 
  t={}; for _,c in pairs(cols or self.cols) do t[1+#t]=c:spread() end; return t end

-- Add new row. If this is the first row, the use the row to create columns.
function Sample:add(t) 
  local function names2Column(      what,new,tmp)
    self.names = t
    for at,name in pairs(t)  do
      what = name:find":" and Col or name:match"^[A-Z]" and Num or Sym
      new  = what(at,name) 
      self.cols[1+#self.cols] = new
      if not name:find":" then
        xy= (name:find"+" or name:find"-" or name:find"!") and self.y or self.x
        xy[ 1+#xy ] = new
        if name:find"!" then self.klass = new end end end 
   end -----------------
   local function row()
     if self.keep then self.rows[ 1+#self.rows ] = t end
     for _,col in pairs(self.cols) do col:add( t[col.at]) end 
   end -------------------------------------------
   if #self.names>0 then row() else names2Column() end end

-- Return a new sampler with same structure as `i`.
function Sample:clone(inits,     i)
   self = Sample:new(self.the)
   add(self, self.names)
   for _,row in pairs(inits or {}) do add(self, row) end
   return self end

-- Return the klass variable
function Sample:klass(row) return row[self.klass.at] end

return {Some=Some, Num=Num, Sym=Sym, Col=Col, Sample=Sample}
