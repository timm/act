package.path = '../src/?.lua'

local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end
local lib  = require"lib"

local fails=0
for _,f in pairs(arg) do
   if f ~= "ok.lua" and f ~= "lua" then
     lib.srand(10014)
     local ok,msg=  pcall(function () dofile(f) end) 
     if   ok 
     then lib.color("green","%s",f)
     else fails=fails+1
          lib.color("red","%s",tostring(msg)) end end end 

for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end
os.exit(fails)
