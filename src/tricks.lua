-- # Misc lib stuff

-- ## Random Stuff

do 
  local Seed0, Seed = 10014, 10014
  -- set seed
  function srand(seed) Seed=seed or Seed0 end 
  -- return random num
  function rand(lo,hi)  
    lo, hi = lo or 0, hi or 1 
    Seed = (16807 * Seed) % 2147483647 
    return lo + (hi-lo) * Seed / 2147483647 end 
  -- return random int
  function randi(lo,hi) 
    return math.floor(0.5 + rand(lo,hi)) end 
end

function any(t) return t[ randi(1,#t) ] end
function anys(t, u) 
  u={}; for _,_ in pairs(t) do u[1+#u]=any(t) end; return u end

function pick(t)
  -- x={"flag",default, help,int|flat|oneof
  local one=function (lo,hi,by) n=(hi-lo)/by; return lo+by*rand(1,n) end 
  v=t.float; if v then return one(v[1], v[2], v[3])    end --{float={lo,hi,by}}
  v=t.int;   if v then return one(v[1], v[2], v[3])//1 end --{int={lo,hi,by}}
  v=t.oneof; if v then return v[randi(1,#v)]           end --{oneof=listOfOptions}
  end
 
-- ## List stuff

-- Combining two tables
function with(t,also) for k,v in pairs(also) do t[k]=v end return t end

-- Sorting lists.
function order(t,fun) table.sort(t,fun); return t  end

-- Randomizing order or list
function shuffle(t,the,     j)
  for i = #t, 2, -1 do
    j = randi(1,i)
    t[i], t[j] = t[j], t[i] end
  return t end

-- First few items in a list
function top(t,n,     u)
  u={}; for i=1,n do u[i]=t[i] end
  return u end

-- Deepcopy
function kopy(t,      seen,      res) 
  seen = seen or {}
  if type(t) ~= 'table' then return t end
  if seen[t] then return seen[t] end
  res = setmetatable({}, getmetatable(t))
  seen[t] = res
  for k,v in pairs(t) do res[kopy(k,seen)]=kopy(v,seen) end
  return res end

-- Return index of `x` in  `t` (or  something close)
function bchop(t,x) 
  local lo, hi = 1, #t
  while lo <= hi do
    local mid =(lo+hi) // 2
    if t[mid] > x then hi= mid-1 else lo= mid+1 end end
  return lo>#t and #t or lo end

--  ## String Stuff

-- Formatting strings
function fmt(...) return string.format(...) end

-- table to string
function out(t,     s,u,mt,pre,ks)
  tmp,ks = {},{}
  for k,_ in pairs(t) do if k:sub(1,1) ~="_" then ks[1+#ks]=k end end
  table.sort(ks)
  for _,k in pairs(ks) do tmp[1+#tmp] = k.."="..tostring(t[k]) end
  return (t._name or "").."("..table.concat(tmp,", ")..")" end

-- print table to string
function shout(t) print(out(t)) end

-- Color a string
function color(s,...)
  local all = {red=31, green=32, yellow=33, purple=34}
    print('\27[1m\27['.. all[s] ..'m'..fmt(...)..'\27[0m') end

-- ## OO Stuff

-- Define a new klass.
function klass(name,      k,mt)
  k= {_name=name, __tostring=out}
  k.__index = k
  mt={__call=function(self,...) return k.new(self,...) end}
  return setmetatable(k,mt) end

-- Create an instance that delegates to `self`.
function isa(self,t,also) 
  for k,v in pairs(also or {}) do t[k] =v end 
  return setmetatable(t,self) end

-- ## File Stuff

-- Reading csv files (each line read as one table)/
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

-- Hunt for a command-line argument.
function cli(flag,b4,_) 
  flag = "-"..flag
  for n,x in pairs(arg) do if x==flag then return tell(n,b4) end
    now = type(b4)=="boolean" and true or tonumber(arg[n+1]) or arg[n+1] end 
    if type(now) == type(b4) then
      return now end 
  return b4 end 
