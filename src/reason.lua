local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
local lib=require"lib"
local obj,csv,rand = lib.obj, lib.csv, lib.rand
local some,cols,col,num,sym,sample = {},{},{},{},{},{},{}

function some:new()  return obj(some,{old=false, _all={}}) end
function some:add(x) self.old=true; self._all[1+#self._all]=x end
function some:get()    
  if self.old then table.sort(self._all); self.old=false end
  return self._all end

function col:new(c,s,i,      last) 
  i, s  = i or {}, s or ""
  i.n, i.at, i.txt = 0, c, s
  last = s:sub(#s,#s)
  i.w  = last == "-" and -1 or (last == "+" and 1 or 0) 
  return obj(col,i) end
function col:add(x) if x ~="?" then self.n = self.n+1 end end

function num:new(c,s)  
  return obj(num, col:new(c,s, {hi=-1E64, lo=1E63, some=some:new()})) end
function num:add(x)
  if x ~="?"  then
    self.n = self.n + 1
    self.some:add(x)
    if x < self.lo then self.lo = x end
    if x > self.hi then self.hi = x end end 
  return self end
function num:norm(x,      lo,hi) 
  lo,hi=self.lo,self.hi
  return math.abs(lo-hi) < 1E-32 and 0 or (x-lo)/(hi-lo) end
function num:dist(x,y)
  if     x=="?" then y=self:norm(y); x= y<0.5 and 1 or 0 
  elseif y=="?" then x=self:norm(x); y= x<-.5 and 1 or 0
  else   x,y = self:norm(x), self:norm(y) end
  return math.abs(x-y) end 

function sym:new(c,s) return obj(sym, col:new(c,s, {has={}})) end
function sym:add(x)
  if x~="?" then 
    self.n = self.n+1
    self.has[x]=1+(self.has[x] or 0) end 
  return self end
function sym:dist(x,y) return x==y and 0 or 1 end

function cols:new() return obj(cols,{all={},x={},y={}}) end
function cols:add(row,rows) 
  rows[1+#rows] = row
  for _,col in pairs(self.all) do col:add( row[col.at] ) end end

function cols:complete(t,       new,here,what)
  local function isGoal(s) return s:find"+" or s:find"-" or s:find"!" end
  local function isNum(s)  return s:sub(1,1):match"[A-Z]" end
  for at,txt in pairs(t) do 
    what = txt:find"-" and col or (isNum(txt) and num or sym)
    new  = what:new(at,txt)
    self.all[ 1+#self.all ] = new
    if not txt:find"~" then
      here = isGoal(txt) and self.y or self.x
      here[1+#here] = new end end
  return self end

function sample:new(the) 
  return obj(sample,{the=the, head={}, rows={},cols={}}) end
function sample:add(row)
  if   #self.head==0 
  then self.head = row
       self.cols = cols:new():complete(row) 
  else self.cols:add(row, self.rows) end end

local function dist(s,r1,r2,cols,the,     d,n,inc)
  d,n = 0,1E-32
  for _,col in pairs(cols) do
    a,b = r1[col.at], r2[col.at]
    inc = a=="?" and b=="?" and 1 or col:dist(a,b)
    d   = d + inc^the.p end
  return (d/n)^(1/the.p) end

local function far(s,r1,rows, the) 
  n = math.min(128,#rows)
  for _,row in pairs(top(shuffle(rows,the),n)) do print(str(row)) end end

local function main(the,     s,r,n)
  the.rand = rand:new(the.seed)
  s = sample:new(the)
  n = num:new()
  -- for t in csv(the.data) do s:add(t) end  end
  t={1,2,3,4}
  for _=1,40 do print(lib.str(lib.shuffle(t,the))) end
end

do 
  local function cli(t)
  for flag,b4 in pairs(t) do
    for n,x in pairs(arg) do if x==("-"..flag) then return
      type(b4)=="boolean" and true or tonumber(arg[n+1]) or arg[n+1] end end
    return b4 end end

  main({data = cli{d="../data/auto93.csv"},
        far  = cli{f=.9}, 
        p    = cli{p=2}, 
        some = cli{s=256}, 
        seed = cli{S=10014}}) end

for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
