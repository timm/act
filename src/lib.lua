-- vim: filetype=lua ts=3 sw=3 sts=3  et :

--  # Misc

local lib={}
local about=require("cli")
local colors,rand,randi,rand,obj,Seed

-- ## Strings

-- Pretty colors
function color(s,...)
   local all = {red=31, green=32, yellow=33, purple=34}
   print('\27[1m\27['.. all[s] ..'m'..string.format(...)..'\27[0m') end

-- String from table (ignoring any "secret" slots, starting with "_").
function show(t,    s,sep,keys)
   s, sep, keys = (t.name or "").."{", "", {}
   ignore = function (s) return type(s)=="string" and s:sub(1,1)=="_" end
   for key,_ in pairs(t) do 
      if not ignore(key) then keys[1+#keys]=key end end
   table.sort(keys)
   for _,key in pairs(keys) do s=s..sep..tostring(t[key]);sep=", " end
   return s.."}"
end

-- ## Objects
function obj(i, name, new)
   new = setmetatable(new or {}, i)
   i.__tostring = show 
   i.__index    = i
   i._name      = name
   return new end

-- ## Random numbers

-- `srand` resets the random number seed;   
-- `randi,rand` generate random integers or floats
Seed = 10014
function srand(s) Seed= s or 10013 end
function randi(lo,hi) return math.floor(0.5 + rand(lo,hi)) end
function rand(lo,hi,     mult,mod)
   lo,hi = lo or 0, hi or 1
   mult, mod = 16807, 2147483647
   Seed = (mult * Seed) % mod 
   return lo + (hi-lo) * Seed / mod end 

return {about=about, color=color, obj=obj,
        rand=rand, randi=randi, srand=srand}
