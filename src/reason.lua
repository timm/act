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

function sampled() return {head={},rows={},cols={},nums={},syms={},x={},y={}} end
function num(c,s) return col(c,s, {hi=-1E64, lo=1E63, all={}}) end
function sym(c,s) return col(c,s, {has={}}) end
function col(c,s,i,      last) 
  i, s  = i or {}, s or ""
  i.n, i.at, i.txt = 0, c, s
  last = s:sub(#s,#s)
  i.w  = last == "-" and -1 or (last == "+" and 1 or 0) 
  return i end

function sample(i,row)
  local function isGoal(s)    return s:find"+" or s:find"-" or s:find"!" end
  local function isNum(s)     return s:sub(1,1):match"[A-Z]" end
  local function isSkip(s)    return s:find"~" end
  local function isMissing(s) return s=="?" end
  local function createColumn(at,txt,       new,here)
    new = (isSkip(txt) and col or (isNum(txt) and num or sym))(at,txt)
    i.cols[ 1+#i.cols ] = new
    if not isSkip(txt) then
      here= isNum(txt)  and i.nums or i.syms; here[1+#here] = new
      here= isGoal(txt) and i.y    or i.x   ; here[1+#here] = new end end 
  local function ok(col,x)   
     if not missing(x) then col.n = col.n+1; return true end end
  local function updateSym(sym,x) 
    if ok(sym,x) then sym.has[x] = 1+(sym.has[x] or 0) end end
  local function updateNum(num,x) 
    if ok(num,x) then 
      num.all[ 1+#col.all ] = x
      num.lo = math.min(num.lo, x)
      num.hi = math.max(num.hi, x) end 
  end ----- begin main --------------
  if #i.head == 0 then
    i.head = t
    for at,txt in pairs(row) do createColumn(at,txt) end
  else  
    i.rows[ 1+#i.rows ] = row 
    for _,col in pairs(i.nums) do updateNum(col, row[col.at]) end 
    for _,col in pairs(i.syms) do updateSym(col, row[col.at]) end end end 

function clone(i,inits) 
  out = sampled()
  sample(out , i.head) 
  for _,row in paris(inits or {}) do sample(out,row) end
  return out end

function main(the, s)
  srand(the.seed)
  s = sampled()
  for t in csv(the.data) do sample(s,t) end end

main{data = cli{d="../data/auto93.csv"},
     far  = cli{f=.9}, 
     p    = cli{p=2}, 
     some = cli{s=256}, 
     seed = cli{S=10014}}

for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
