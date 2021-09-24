# Coding Standards

`the`: stores the config. To allos clear cnfiguration,
all  code needs to pass around their own local version
of `the`.

``the` is build from `about` which stores nit jsut the options
but also the help text for each option plus 
contact and license information
for the code.

No gloabl variables: everything is declared `local` before use.
Functions called with `n` argues should define their locals
as arguments `n+1, n+2 etc.

Inheritance=no:  Too hard for begineers.

Polymorphiusm=yes: spreads out the code. New isntances are defined using e.g.

```lua
local isa=setmetatable
local Num,Sym={},{}
local col

-- Stores command parts of other  instances
function col(at,txt) 
  return {at=at,txt=txt,n=0,w=txt:find("-") and -1 or 1} end

-- Num constructor
function Num.new(at,txt) 
  i = isa(col(at,txt),Num)
  i.mu, i.m2,i.sd, i.lo,i.hi = 0,0,0,inf, -inf
  return i end

-- Sym constructor
function Sym.new(at,txt)
  i = isa(col(at,txt), Sym)
  i.has={}
  return i end
```



