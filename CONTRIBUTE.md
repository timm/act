# Coding Standards

## The Sequence

Note: validation  introduced very early.

|week|file | notes|
|----|-----|--------|
|  1|about  | config defaults||
|  1|cli    | how to  override the defaults (from the command line); and (2) run test cases|
|  2|sample | how to collect  statistics on columns  of data, incremental standard deviation,reservoir sampling|
|  3|gap    | knn, cluster  |random projections (with  Fastmap)|
|  6|bayes  | naive bayes,   Sequential Model Optimization, TPE(ish), |
|  4|whatis | classification (very simple, knn),  validation, zeror|
|  5|valid  | cliffs-delta, bootstrap, scott-knot|
|  7|what2do| discretization, contrast set learning| planning, monitoring, Fayyad-Irrani,  chi-merge|
|  8|xplain | rule generation  |
|  9|tree   | recursive rule generation  (a.k.a. Decision trees)|
| 10|guess  | semi-supervised learning    |
| 11|steam  | anomaly detection, streaming, active learning,  semi-supervised learning|

## Files

     about --> lib --> class --> sample -->  

## Coding standards

Short code. 
- line   length max=80
- tabs= 3  spaces (yes, I know 2 is cooler but some large Lua projects use 3 so  let us bow  before their  wisdom).
- Consider writing trailing `end`s on  same lines. 
- Try  to  use one-line functions.

Try to  avoid typing  `local`  all over the code.
- e.g. declare the  file locals at top of file
- e.g. functions called with `n` argues should define their locals
  as arguments `n+1, n+2 etc.

`the`: stores the config. To allow cleaner configuration,
all  code needs to pass around their own local version
of `the`.

``the` is build from `about` which stores nit jsut the options
but also the help text for each option plus 
contact and license information
for the code.

No global variables: 
- Everything is declared `local` before use.
- first lines of code should  trap initial globals, 

     local b4={}; for k,_ in pairs(_ENV) do b4[k]=k end

- Then, second  last line (before any final returns) 
  should  warn if  anything was added to  that global set.

     for k,_ in pairs(_ENV) do if not b4[k] then print("?? "..k) end end

Inheritance=no:  too much conceptual  overhead for  too  little gain,
Once  you've got polymorphism going, the next net benefit of moving on to inheritance  
may not be large
https://doi.org/10.1109/52.676735.

Polymorphism=yes: spreads out the code. New instances are defined using `isa`:

    obj(self, "KlassPringString", {slot1=value1, slot2=value2 etc}

For example:

```lua
do
   local col,with
   local Num,Sym={},{}

   function col(at,txt)  -- common slots
      at  = at or 0
      txt = txt or ""
      w   = "-"==txt:sub(#s,#s) and -1 or 1
      return {at=at, txt=txt, n=0, w=w} end
   
   function Sym:new(at, name) -- for symbolic columns
      return obj(self,"Sym", with(col(at,txt), {has={}, mode="", most=0})) end
   
   function Num:new(at,txt)  -- for  numeric  columns
      return obj(self,"Num",
         with(col(at,txt), {mu=0, m2=0, sd=0, lo= inf, hi= -inf})) end end

   function with(2ddt1,t2)
      for k,v in pairs(t2) do t1[k]=v end end
```



