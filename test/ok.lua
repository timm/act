
local b4={}; for k,v in pairs(_ENV) do b4[k]=v end
require"tricks"

local fails=0
for _,f in pairs(arg) do
  if f ~= "ok.lua" and f ~= "lua" then
    local ok,msg = pcall(function () dofile(f) end) 
    if   ok 
    then color("green","%s",f)
    else color("red","%s",tostring(msg)); fails=fails+1 end end end 

for k,v in pairs(_ENV) do 
  if not b4[k] and type(v) ~= "function" then 
     print("?? ",k,type(v))  end end 

os.exit(fails)
