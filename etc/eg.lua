
local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
local rat  = require"rat"
local rand = require"rand"
local list = require"list"

function randi(lo,hi) 
  return math.floor(0.5 + rand(lo,hi)) end

function rand(lo,hi,     mult,mod)
  lo,hi = lo or 0, hi or 1
  mult, mod = 16807, 2147483647
  Seed = (mult * Seed) % mod 
  return lo + (hi-lo) * Seed / mod end 

local function srand(s) 
  Seed = s or 10013 end

local fails=0
for _,f in pairs(arg) do
   if f ~= "ok.lua" and f ~= "lua" then
     Seed =rand.srand(the.seed)
     local ok,msg=  pcall(function () dofile(f) end) 
     if   ok 
     then str.color("green","%s",f)
     else fails=fails+1
          str.color("red","%s",tostring(msg)) end end end 

for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
os.exit(fails)function a() return a end
