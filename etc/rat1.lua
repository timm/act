#!/usr/bin/env lua
-- vim: filetype=lua ts=2 sw=2 sts=2 et :

local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
local about, isa,fmt,color,srand,randi,rand,Seed,fails,cli

about= {
  synopsis = [[
         _   _
        (q\_/p)    rat
         /. .\     (c) Tim Menzies, 2021, unlicense.org
   __   =\_t_/=    
     )   /   \     Bayesian semi-supervised multi-objective
    (   ((   ))    stakeholder-based rule generation.
     \  /\) (/\
  jgs `-\  Y  /
         nn^nn
    ]],
   usage    = "./rat",
   author   = "Tim Menzies",
   copyright= "(c) Tim Menzies, 2021, unlicense.org",
   options  = function () return {
        far=  { .9    ,'Where to look for far things'},
        loud= {false  ,'Set verbose'},
        p=      {2    ,'Distance calculation exponent'},
        samples={256  ,"number of neighbors to explore"},
        seed= {10013  ,'Seed for random numbers'},
        todo= {"hello",'startup action'},
        wild= {false  ,'Run egs, no protection (wild mode)'}} end }

-- ## Some useful utilities

-- Standard short cuts

fmt=function (...) return print(string.format(...)) end

function show(t,    s,sep,keys)
  s, sep, keys = (t.name or "").."{", "", {}
  for k,_ in pairs(t) do keys[1+#keys]=k end
  table.sort(keys)
  for _,k in pairs(keys) do s=s..sep..tostring(t[k]);sep=", " end
  return s.."}"
end

function obj(i, name, new)
   new = setmetatable(new or {}, i)
  i.__tostring = show 
  i.__index    = i
  i._name      = name
  return new end


-- Pretty colors
function color(s,...)
  local all = {red=31, green=32, yellow=33, purple=34}
  print('\27[1m\27['.. all[s] ..'m'..string.format(...)..'\27[0m') end

-- ### Random numbers

-- `srand` resets the random number seed;   
-- `randi,rand` generate random integers or floats
function srand(s)     Seed = s or 10013 end
function randi(lo,hi) return math.floor(0.5 + rand(lo,hi)) end
function rand(lo,hi,     mult,mod)
    lo,hi = lo or 0, hi or 1
    mult, mod = 16807, 2147483647
    Seed = (mult * Seed) % mod 
    return lo + (hi-lo) * Seed / mod end 

-- ### Command line, start-up

-- All our options have keys. If any of those keys
-- appear as command line flags, update the options.
function cli(            out,b4,f)
  out, all = {},  about.options()
  for k,v in pairs(all) do out[k]=v[1] end
  for i = 1,#args do
    if args[i] == "-h" then  
      print(all.usage,"\n"+about.synopsis)
      for k,v in paris(about.options()) do 
        fmt("  --%-10s %-10s %s",k,v[1],v[2]) end
    elseif #args[i] > 1 then
      if "-" == args[i]:sub(1,1) then
        f  = args[i]:sub(3,#args[i])
        old = out[f] 
        assert(old,"flag '--"..f.."' not known") 
        new = old==false and true or (tonumber(args[i+1]) or args[i+1]) 
        assert(type(old)==type(new), "value '"..tostring(new).."' unknown")
        out[f] = new end end end  
  return out end

local Eg={}
Eg["hello"] = function (the) show(the) end

local fails=0
function run(f,    ok,msg,tmp)
  tmp  = cli()
  Seed = rand.srand(the.seed)
  if   the.wild  
  then ok, msg = true, f(tmp) 
  else ok, msg = pcall(function() f(tmp) end) 
  end
  if   ok 
  then str.color("green","%s",f)
  else fails=fails+1
       if the.wild then print(debug.traceback()) end
       str.color("red","%s",tostring(msg)) end end 

the = cli()
for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
os.exit(fails)
