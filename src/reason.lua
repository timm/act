local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
local wght, klass, num, map, just, cli, csv, main
local Seed, srand, rand, randi
function map(t,f,     b)
  b={}; for i,v in pairs(t) do b[i]=f(v) end 
  return b end 

function with(t,f,   b)
  b={}; for i,v in pairs(t) do if f(v) then b[i]=f(v) end end
  return b end 

function without(t,f) return with(t,function(v) return not f(v) end) end

function cli(t)
  for flag,b4 in pairs(t) do
    for n,x in pairs(arg) do if x==("-"..flag) then return
      type(b4)=="boolean" and true or tonumber(arg[n+1]) or arg[n+1] end end
    return b4 end end

function str(t)
  local function kv(a)
    for k,v in pairs(t) do a[1+#a]=fmt("%s=%s", k, str(v)) end 
    return a end
  return type(t)~="table" and tostring(t) or  ( 
    #t>0 and '{'..table.concat(map(t,tostring),", ")..'}' or str(kv({}))) end

Seed = 10014
function srand(s) Seed= s or 10013 end
function randi(lo,hi) return math.floor(0.5 + rand(lo,hi)) end
function rand(lo,hi)
   lo, hi = lo or 0, hi or 1
   Seed = (16807 * Seed) % 2147483647 
   return lo + (hi-lo) * Seed / 2147483647 end 

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

function sample() return {head={},rows={},cols={},num={},sym={},x={},y={}} end
function num(c,s) return col(c,s, {hi=-1E64, lo=1E63, all={}}) end
function sym(c,s) return col(c,s, {has={}}) end
function col(c,s,i) 
  i,s = i or {}, s or ""
  i.n, i.at, i.txt = 0, c, s
  i.w = s:sub(#s,#s) == "-" and -1 or (s:sub(#s,#s) == "+" and 1 or 0) 
  return i end

function add(s,t)
  local function isGoal(s) return s:find"+" or s:find"-" or s:find"!" end
  local function isNum(s)  return s:sub(1,1):match"[A-Z]" end
  local function isSkip(s) return s:find"?" end
  local function header(c,x,       new,here)
    new = (isSkip(x) and col or (isNum(x) and num or sym))(c,x)
    s.cols[ 1+#s.cols ] = new
    if not isSkip(x) then
      here = isNum(x)  and s.num or s.sym; here[ 1+#here ] = new
      here = isGoal(x) and s.y   or s.x  ; here[ 1+#here ] = new end 
  end ------------------------
  local function update(col,x)
    if x ~= "?" then 
      col.n = col.n + 1
      if   col.lo 
      then col.all[ 1+#col.all ] = x
           col.lo = math.min(col.lo, x)
           col.hi = math.max(col.hi, x)
      else col.has[x] = 1+(col.has[x] or 0) end end 
  end --------------
  if   #s.head == 0 
  then s.head = t
       for c,x in pairs(t) do header(c,x) end
  else s.rows[ 1+#s.rows ] = t 
       for c,x in pairs(t) do update(cols[c],x) end end end 

function main(the, s)
  srand(the.seed)
  s = sample()
  for t in csv(the.data) do add(s,t) end end

main{data = cli{d="../data/auto93.csv"},
     far  = cli{f=.9}, 
     p    = cli{p=2}, 
     some = cli{s=256}, 
     seed = cli{S=10014}}

for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
