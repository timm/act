local b4={}; for k,v in pairs(_ENV) do b4[k]=v end
local about = {wait=10, seed=1,k=2,  p=2, data="../data/auto93.csv"}

function sample(the,it,new)
  if not it then
    it = {the=the, cols={}, head=t, lo={}, hi={}, rows={}}
    for c,txt in pairs(new) do 
      if txt:match("^[A-Z]") then new.lo[c], new.hi[c] = 1E32,-1E22 end 
      if not txt:find"~" then it.cols[c] = c end end
  else
    it.rows[ 1+#it.rows ] = new
    for c,_ in pairs(i.lo) do
      v = new[c]
      if v~="?" then
        if v < it.lo[c] then it.lo[c] = v end
        if v > it.hi[c] then it.hi[c] = v end end end end
  return it end

function knn(the,it)
  for n,t in csv(the.data) do 
    if n>10 then classify(it,t) end
    it= sample(the,it,t) 
    end end

function norm(lo,hi,x)
  return (x=="?" and "?") or (math.abs(x-y)<1E-32 and 0) or (x-lo)/(hi-lo) end  

function dist(it,row1,row2,cols)
  local function  dist1(c,x,y)
    lo, hi = it.lo[c], it.hi[c]
    if     x=="?" then y= norm(lo,hi,y); x=y>0.5 and 0 or 1 
    elseif y=="?" then x= norm(lo,hi,x); y=x>0.5 and 0 or 1 
    else   x,y= norm(lo,hi,x), norm(lo,hi,y) end
    return math.abs(x-y) 
  end ------------------------
  d, n, p = 0, 1E-32, it.the.p
  for c,_ in pairs(cols or it.cols) do
    x,y=row1[c],row2[c]
    if     x=="?" and y=="?" then inc = 1
    elseif it.lo[c]          then inc = dist1(c,x,y)
    else   inc = x==y and 0 or 1 
    end 
    d = d+ inc^p end
  return (d/n)^(1/p) end
    
function neighbors(it,r1,rows)
  tmp={}
  for _,row2 in pairs(rows or it.rows) do t[1+#t]={dist(it,row1,row2),row2} end
  table.sort(tmp, function (x,y) return x[1] <  x[2] end)
  return tmp end

function classify(it, t)
function atom(x) return tonumber(x) or x end
function shout(t) print(out(t)) end

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

function cli(b4)
  for n,v in pairs(arg) do 
    if v:sub(1,1)=="-" then 
      x = v:sub(2,#v) 
      b4[x] = b4[x]==false and true or atom(arg[n+1]) end end 
  return b4 end

local fails=0
for k,v in pairs(_ENV) do 
  if not b4[k] and type(v) ~= "function" then print("?? ",k) end end 
os.exit(fails)
