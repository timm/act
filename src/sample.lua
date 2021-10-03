require"about"
require"tricks"

-- ## Dispatch 

-- Add things that we aren't skipping (icnrementing `n` as we go).
function add(i,x) 
  if x ~= "?" then
    i.n = i.n + 1
    return i.Is.add(i,x) end end

-- Report central tendency.
function mid(i)    return i.Is.mid(i) end 

-- Report the wriggle around the central tendancy.
function spread(i) return i.Is.spread(i) end 

-- ## Some

-- Reservoir sampler (of size of `max`). 
Some={}
function Some.new(max) 
  return {Is=Some, n=0, max=max or 256, old=true, Has={}} end

--Add to a reservoir sampling. If full, replace anything at random.
function Some.add(i,x) 
  r = math.random
  if     #i.Has < i.max     then pos = 1+#i.Has 
  elseif r()    < i.max/i.n then pos = 1+(r()*#i.Has)//1 end 
  if pos then 
    i.old=true
    i.Has[pos]=x end end

-- Return the contents, sorted.
function has(i)  
  i.old= i.old and order(i.Has) or i.Has; i.old=false; return i.Has end

-- Report the `p-th` value within the sorted contents.
function per(i,p) a= a or has(i); return a[ ((p or .5)*#a) // 1 ] end

-- ## Col

-- Abstract class for columns.
Col={}
function Col.new(at,name) return {Is=Col, at=at or 1, name=name or "", n=0} end

-- "Adding" means do nothing so the  central ten dances and spreads never change.
function Col.add(i,x) return x end
function Col.mid(i) return "?" end
function Col.spread(i) return 0 end

-- ## Sym

-- Counter for symbols.
Sym={}
function Sym.new(at, name)  
  return with(Col.new(at,name), {Is=Sym, has={}, mode="", most=0}) end

-- Adding means updating symbol count (and the `mode`).
function Sym.add(i,x) 
  i.has[x] = 1 + (i.has[x] or 0)
  if i.has[x] > i.most then i.most, i.mode = i.has[x], x end end

-- `mid` means `mode`.
function Sym.mid(i) return i.mode end

-- `Spread` means entropy.
function Sym.spread(i,   e)
  for v in pairs(i.has) do e = e - v/i.n * math.log(v/i.n,2) end
  return e end

-- ## Num

-- counter for numbers
Num={}
function Num.new(at,name) 
  i= with(Col.new(at,name), {Is=Num,some=Some.new(), lo=1E32, hi=-1E32})
  i.w = i.name:find"+" and 1 or i.name:find"-" and -1 or 0
  return i end

-- Keep some numbers, update `lo`, `hi`
function Num.add(i,x)
  add(i.some, x)
  if x > i.hi then i.hi = x end
  if x < i.lo then i.lo = x end end

-- Central tendency.
function Num.mid(i)    return  per(i.some,.5) end
-- Spread around the central  tenancy means standard deviation
-- (Aside: we all know that +- 1,2 standard deviations is 66,95% of the mass.
-- Well, what else is true is that +- 1.28 standard deviations 
-- is 90% of the pass. To say that another way, (90-10)th/(1.28*2)
-- is one standard deviation.)
function Num.spread(i) return (per(i.some,.9) - per(i.some,.1))/2.54 end
-- Normalize
function norm(i,x) return math.abs(x-y)<1E-32 and 0 or (x-i.lo)/(i.hi-i.lo) end

-- ## Sample

-- holder of rows and columns
Sample={}
function Sample.new(inits,       i)
  i = {Is=Sample, rows={},keep=true,cols={},names={},x={},y={}}
  if type(inits)=="table" then
    for _,row in pairs(inits or {}) do add(i,row) end end
  if type(inits)=="string" then
    for t in csv(inits) do row(i,t) end end
  return i end

-- Report the mid of certain columns (defaults to "use all")
function Sample.mid(i, cols) 
  t={}; for _,c in pairs(cols or i.cols) do t[1+#t]=mid(c) end; return t end

-- Report the spread of certain columns (defaults to "use all")
function Sample.spread(i, cols) 
  t={}; for _,c in pairs(cols or i.cols) do t[1+#t]=spread(c) end; return t end

-- Add new row. If this is the first row, the use the row to create columns.
function row(i,t) 
  local function names2Column(      what,new,tmp)
    i.names = t
    for at,name in pairs(t)  do
      what = name:find":" and Col or name:match"^[A-Z]" and Num or Sym
      new  = what.new(at,name) 
      i.cols[1+#i.cols] = new
      if not name:find":" then
        xy= (name:find"<" or name:find">" or name:find"!") and i.y or i.x
        xy[ 1+#xy ] = new
        if name:find"!" then i.klass = new end end end 
   end -----------------
   local function data()
     if i.keep then i.rows[ 1+#i.rows ] = t end
     for _,col in pairs(i.cols) do add(col, t[col.at]) end 
   end -------------------------------------------
   if #i.names>0 then data() else names2Column() end end

-- Return a new sampler with same structure as `i`.
function clone(i, inits,     i)
   i = Sample.new()
   add(i,i.names)
   for _,row in pairs(inits or {}) do add(i,row) end
   return i end
