local b4={}; for k,v in pairs(_ENV) do b4[k]=v end
local use=require"use"

local function color(s,...)
  local all = {red=31, green=32, yellow=33, purple=34}
   print('\27[1m\27['.. all[s] ..'m'..fmt(...)..'\27[0m') end

local fails=0
for _,f in pairs(arg) do
  if f ~= "lua" then
    local ok,msg = pcall(function () use(f) end) 
    if   ok 
    then color("green","%s",f)
    else color("red","%s",tostring(msg)); fails=fails+1 end end end 

for k,v in pairs(_ENV) do 
  if not b4[k] then  print("?? ",k,type(v))  end end 

os.exit(fails)
