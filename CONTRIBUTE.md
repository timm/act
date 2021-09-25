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
- tabs= 3  spaces
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

No global variables: everything is declared `local` before use.

Inheritance=no:  too much conceptual  overhead for  too  little gain,

Polymorphism=yes: spreads out the code. New instances are defined using `isa`:

    obj(self, "KlassPringString", {slot1=value1, slot2=value2 etc}

For example:

```lua
do
   local col,with
   local Num,Sym={},{}
   function col(at,txt)  -- common slots
      return {at=t, txt=txt, n=0, w=(txt:find("-") and -1 or 1)} end
   function with(t1,t2)
      for k,v in pairs(t2) do t1[k]=v end end
   
   function Sym:new(at, name) -- for symbolic columns
      return obj(self,"Sym",
         with(col(at,txt), {has={}, mode=None, most=0})) end
   
   function Num:new(at,txt)  -- for  numeric  columns
      return obj(self,"Num",
         with(col(at,txt), {mu=0, m2=0, sd=0, lo=inf, hi= -inf})) end end
```



