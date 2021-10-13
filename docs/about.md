Inexact, but Reasonable   
(c) Tim Menzies, Jamie Jennings 2022    
-------------     
[about](about.md) :: [ish](is.md) :: [etc](etc.md)    


# Options
    
The behavior of inexact algorithms is determins by numerous control options.

Exploring those options is intself an ineaxt process since it means trading off mulitlple design considerations.

- **LESSON**: The users of inexact alogirhms need some method to quickly explore all those options (in a multi-objective space).


```lua
local function cli(flag, b4)
  for n,v in pairs(arg) do if v==flag then 
    return (b4==false) and true or (tonumber(arg[n+1]) or arg[n+1]) end end 
   return b4 end

local  defaults= {
  combine= cli("-c", "mode"),
  data=    cli("-d", "../data/auto93.csv"),
  k=       cli("-k", 2),  
  p=       cli("-p", 2), 
  seed=    cli("-S", 10014),   -- random number see
  some=    cli("-s", 256),     -- use this many randomly nearest neighbors
  todo=    cli("-t", "hello"), -- default start up is to run Eg["todo"]
  wait=    cli("-w", 10)       -- start classifying after this many rows
}
return function(  t) t={}; for k,v in pairs(defaults) do t[k]=v end; return t ed
```
