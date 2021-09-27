local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end

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

local function str(t1,  t2)
  t2={}; for k,v in  pairs(t1) do t2[k]=tostring(v) end
  return "{"..table.concat(t2,",  ").."}" end

local function obj(self, new)
  self.__tostring, self.__index = str,self 
  return setmetatable(new or {}, self) end

local rand={}
function rand:new(seed)   return obj(rand,{seed=seed or 10014})  end
function rand:int(lo,hi); return math.floor(0.5 + self:next(lo,hi)) end
function rand:next(lo,hi) 
  lo, hi = lo or 0, hi or 1
  self.seed = (16807 * self.seed) % 2147483647 
  return lo + (hi-lo) * self.seed / 2147483647 end 

local some={}
function some:new() return obj(some,{old=false, _all={}}) end
function some:add(i,n) self.old=true; self._all[1+#self._all] = x end
function some:all(i)    
  if self.old then table.sort(self._all); self.old=false end
  return self._all end

local col={}
function col:new(c,s,i,      last) 
  i, s  = i or {}, s or ""
  i.n, i.at, i.txt = 0, c, s
  last = s:sub(#s,#s)
  i.w  = last == "-" and -1 or (last == "+" and 1 or 0) 
  return obj(col,i) end
function col:add(x) if x ~="?"  then self.n = self.n+1 end end

local num={}
function num:new(c,s)  
  return obj(num, col(c,s, {hi=-1E64, lo=1E63, some=some:new()})) end
function num:add(x)
  if x ~="?"  then
    self.n = self.n + 1
    self.some:add(x)
    if x < self.lo then self.lo = x end
    if x > self.hi then self.hi = x end end end

local sym={}
function sym:new(c,s)  return obj(sym, col(c,s, {has={}})) end
function sym:add(x)
  if x~="?" then 
    self.n = self.n+1
    self.has[x]=1+(self.has[x] or 0) end end

local cols={}
function cols:new(t) 
  self = obj(cols,{all={},x={},y={}}) 
  local function isGoal(s) return s:find"+" or s:find"-" or s:find"!" end
  local function isNum(s)  return s:sub(1,1):match"[A-Z]" end
  for at,txt in pairs(t) do 
    new = (txt:find"-" and col or (isNum(txt) and num or sym0)):new(at,txt)
    self.all[ 1+#self.all ] = new
    if not txt:find"~" then
      here= isNum(txt)  and self.nums or self.syms; here[1+#here] = new end end
  return self end
function cols:add(row) for _,col in pairs(self.all) do col:add(row[col.at]) end  end

local sample={}
function sample:new() 
  return {head={},rows={},cols={},nums={},syms={},x={},y={}} end
function sample:add(row)
  if   #self.head == 0 
  then self.cols = cols:new(row); self.head=t
  else self.cols:add(row)       ; self.rows[1+#self.rows]=row end end

function main(the, s)
  srand(the.seed)
  s = sampled()
  for t in csv(the.data) do sample(s,t) end end

do 
  local function cli(t)
    for flag,b4 in pairs(t) do
      for n,x in pairs(arg) do if x==("-"..flag) then return
        type(b4)=="boolean" and true or tonumber(arg[n+1]) or arg[n+1] end end
      return b4 end end

  main{data = cli{d="../data/auto93.csv"},
       far  = cli{f=.9}, 
       p    = cli{p=2}, 
       some = cli{s=256}, 
       seed = cli{S=10014}} end

for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
