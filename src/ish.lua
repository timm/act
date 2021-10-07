local b4={}; for k,v in pairs(_ENV) do b4[k]=v end
local isa,klass,knn,push,atom,shout,out,cli
local Sym,Skip,Num,Sample
local about = {wait=10, seed=1,k=2,  p=2, data="../data/auto93.csv"}

-- make instance
function isa(mt,t) return setmetatable(t,mt) end
-- make klass
function klass(name) k={_name=name};k.__index=k; return k end

Skip=klass"Skip"
function Skip.new(at,txt) return isa(Skip,{at=at,txt=txt}) end
function Skip:add(x) return x end

Sym=klass"Sym"
function Sym.new(at,txt) 
  return isa(Sym,{at=at,txt=txt,mode=nil,most=1,has={}},Num) end
function Sym:dist(x,y) 
  return  x==y and 0 or 1 end
function Sym:add(x) 
  self.has[x]  = 1 + (self.has[x] or 0) 
  if self.has[x] > most then
    most,mode=self.has[x], x end end

Num=klass"Num"
function Num.new(at,txt) 
  return isa(Num,{at=at,txt=txt,lo=1E32,hi=-1E32},Num) end
function Num:add(x)
  if x~="?" then
    self.lo = math.min(self.lo,x)
    self.hi = math.max(self.hi,x) end end
function Num:dist(x,y)
  if     x=="?" then y = self:norm(x); x = y>.5 and 0  or 1
  elseif y=="?" then x = self:norm(x); y = x>.5 and 0  or 1
  else   x,y = self:norm(x), self:norm(y)  end
  return math.abs(x-y) end
function Num:norm(x)
  lo,hi=self.lo,self.hi
  return (x=="?" and x) or (math.abs(lo-hi)<1E-32 and 0) or (x-lo)/(hi-lo) end  
  
Sample=klass"Sample"
function Sample.new(the) 
  return isa(Sample,{the=the,ys={},xs={},xys={},head={},rows={},klass=nil}) end

function Sample:add(new)
  local function isGoal(s) return s:find"+" or s:find"-" or s:find"=" end
  local function isNum(s)  return s:match("^[A-Z]") end
  if #self.xys>0 then
    for _,col in pairs(self.xys) do col:add(new[col.at]) end
    push(self.rows,new)
  else
    self.head=new
    for at,txt in pairs(new) do 
      new=((txt:find"~" and Skip) or (isNum(txt) and Num or Sym))(at,txt)
      push(self.xys,new)
      if not txt:find"~" then
        if txt:find"=" then self.klass = new end
        push(isGoal(txt) and self.y or self.x, new) end end end end

function Sample:dist(row1,row2,cols)
  d, n, p = 0, 1E-32, self.the.p
  for _,col in pairs(cols or self.xs) do
    x,y = row1[col.at],row2[colt.at]
    inc = x=="?" and y=="?" and 1 or col:dist(x,y)
    d   = d + inc^p 
    n   = n + 1 end
  return (d/n)^(1/p) end
    
function Sample:neighbors(r1,rows,cols,    t)
  t={}
  for _,row2 in pairs(rows or self.rows) do 
    push(t, {self:dist(row1,row2,cols),row2}) end
  table.sort(t, function (x,y) return x[1] < y[1] end)
  return t end

function knn(the,  s)
  local function classify(row) 
    around = s:neighbors(row)
    seen   = Sym.new()
    for i=1,the.k do seen:add()
  s=Sample.new(the)
  for n,t in csv(the.data) do 
    if n>10 then classify(it,t) end
    s:add(t)
    end end

-- ## Misc
-- Shortcut
push=table.insert
-- Coerce things to numbers, if they want to
function atom(x) return tonumber(x) or x end
-- Print a string of a table
function shout(t) print(out(t)) end
-- Convert a table to astring
function out(t,     tmp,ks)
  tmp,ks = {},{}
  for k,_ in pairs(t) do if k:sub(1,1) ~= "_" then  ks[1+#ks]=tostring(k)  end end
  table.sort(ks)
  for _,k in pairs(ks) do tmp[1+#tmp] = k.."="..tostring(t[k]) end
  return (t._name or "").."("..table.concat(tmp,", ")..")" end
-- Read rows from csv file
function csv(file,      n,split,stream,tmp)
  stream = file and io.input(file) or io.input()
  tmp    = io.read()
  n      = 0
  return function(       t)
    if tmp then
      t, tmp = {}, tmp:gsub("[\t\r ]*",""):gsub("#.*","")
      for y in string.gmatch(tmp, "([^,]+)") do t[#t+1]=y end
      tmp = io.read()
      if  #t > 0 then
        for j,x in pairs(t) do t[j] = atom(x) end
        n = n + 1
        return n,t end
    else io.close(stream) end end end
-- Update defaults (the  `b4` table) with info from command line.
function cli(b4)
  for n,v in pairs(arg) do 
    if v:sub(1,1)=="-" then 
      x = v:sub(2,#v) 
      b4[x] = b4[x]==false and true or atom(arg[n+1]) end end 
  return b4 end

local fails=0
for k,v in pairs(_ENV) do if not b4[k]  then print("?? ",k) end end 
os.exit(fails)
