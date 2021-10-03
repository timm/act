require"about"
require"tricks"

-- Polymorphism
function add(i,x) 
  if x ~= "?" then
    i.n = i.n+1
    return i.Is.add(i,x) end end
function mid(i)    return i.Is.mid(i) end 
function spread(i) return i.Is.spread(i) end 

-- Reservoir sampler (of upper size of `max`). When full, delete anything at random.
Some={}
function Some.new(max) 
  return {Is=Some,n=0,max=max or 256,old=false,has={}} end

function Some.add(i,x) 
  r = math.random
  if     #i.has < i.max     then pos = 1+#i.has 
  elseif r()    < i.max/i.n then pos = 1+(r()*#i.has)//1 end 
  if pos then 
    i.old=true
    i.has[pos]=x end end

function has(i)  
  i.old = i.old and order(i.has) or i.has; i.old=false; return i.has end

function per(i,p) 
  a = a or has(i)
  p = p or 0.5
  return a[ p*#a // 1 ] end

-- Abstract class for columns.
Col={}
function Col.new(at,name) 
  local function w(s) return s:find"+" and 1 or (s:find"-" and -1 or 0) end
  return {Is=Col, at=at or 1, name=name or "", n=0, w = w(name or "")} end

function Col.add(i,x) return x end

-- counter for symbols
Sym={}
function Sym.new(at, name)  
  return with(Col.new(at,name), {Is=Sym,has={}, mode=0,_most=0}) end

function Sym.add(i,x) 
  i.has[x] = 1 + (i.has[x] or 0)
  if i.has[x] > i.most then i.most, i.mode = i.has[x], x end end

function Sym.mid(i) return i.mode end

function Sym.spread(i,   e)
  for v in pairs(i.has) do e = e - v/i.n * math.log(v/i.n,2) end
  return e end

-- counter for numbers
Num={}
function Num.new(at,txt) 
  return with(Col.new(at,name), {Is=Num,some=Some.new(), o=-1E32,hi=1E32}) end

function Num.add(i,x)
  add(i.some, x)
  if x > i.hi then i.hi = x end
  if x < i.lo then i.lo = x end end

function Num.mid(i)    return  per(i.some,.5) end
function Num.spread(i) return (per(i.some,.9) - per(i.some,.1))/2.54 end

-- holder of rows and columns
Sample={}
function Sample.new(inits,       i)
  i = {rows={},keep=true,cols={},names={},x={},y={}}
  for _,row in pairs(inits or {}) do add(i,row) end  
  return i end
 
function Sample.add(i,t) 
  local function names2Column(   what,new,tmp)
    i.names = t
    for at,name in pairs(t)  do
      what = name:find"~" and Col or (name:match("^[A-Z]") and Num or Sym)
      new  = what.new(at,name) 
      i.cols[1+#i.cols] = new
      if not name:find"~" then
        tmp= (name:find"<" or name:find">" or name:find"!") and i.y or i.x
        tmp[ 1+#tmp ] = new
        if name:find"!"then i.klass = new end end end 
   end -----------------
   local function data()
     if i.keep then i.rows[ 1+#i.rows ] = t end
     for _,col in pairs(i.cols) do add(col, t[col.at]) end 
   end -------------------------------------------
   if #i.names>0 then data() else names2Column() end end

function Sample.mid(i) 
  t={}; for _,c in pairs(i.cols) do t[1+#t]=mid(c) end; return t end

function Sample.spread(i) 
  t={}; for _,c in pairs(i.cols) do t[1+#t]=spread(c) end; return t end

function load(i,file) for row in csv(file) do add(i,row) end; return i end

function clone(i, inits,     i)
   i = Sample.new()
   add(i,i.names)
   for _,row in pairs(inits or {}) do add(i,row) end
   return i end
