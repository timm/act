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

=======
-- infinity
inf = 1E64
-- Polymorphsim support
isa=setmetatable
-- printf-like printing; e.g. `fmt("%-10s, %5.sf","level", 22/7)`
fmt=function (...) return print(string.format(...)) end

-- ## Columns

-- For numbers, symbols, things to skip
local Num,Sym,Skip = {},{},{} 

-- All columns know  their column number, column name, 
function col(at,txt) 
  return {at=at,txt=txt,n=0,w=txt:find("-") and -1 or 1} end

function Num.new(at,txt) 
  i = isa(col(at,txt),Num)
  i.mu, i.m2,i.sd, i.lo,i.hi = 0,0,0,inf, -inf
  return i end

function Sym.new(at,txt)
  i = isa(col(at,txt), Sym)
  i.has={}
  return i end

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

