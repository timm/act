import re,math,random,functools
from math import inf
from random import random as r

CONFIG = dict(    
  far  = (float,0.9, "how far to reach for 'distant' examples"),
  file = (str, "data/auto93.csv", "input data file"),
  loud = (bool, False,"loud mode: print stacktrace on error"),    
  p    = (int,  2,    "co-efficient on distance equation"),    
  samples=(int,128,    "number of samples used when finding far items"),
  seed = (int,  10014,  "random number seed"),      
  todo = (str,  "",   "todo: function (to be run at start-up)"),     
  Todo = (str, False, "list available items for -t"))     

class o:
  "return a class can print itself (hiding 'private' keys)"
  def __init__(i, **d)  : i.__dict__.update(d)
  def __repr__(i) : return "{"+ ', '.join([
    f":{k} {v}" for k, v in i.__dict__.items() if  k[0] != "_"])+"}"

class Col(o):
  def __init__(i,at=0,txt=""): i.n,i.at,i.txt = 0,at,txt
  def add(i,x): 
    if x == "?": return x
    i.n += 1
    return i.add1(x)
  def add1(i,x): ...

class Num(Col):
  max = 128
  def __init__(i,**k): 
    super().__init__(**k)
    i.lo, i.hi, i.w = inf, -inf, (-1 if "-" in i.txt else 1)
    i._all, i.old = [], True

  def add1(i,x): 
    x    = float(x)
    i.lo = min(x, i.lo)
    i.hi = max(x, i.hi)
    if len(i._all) < Num.max: 
      i.old = True;
      i._all += [x]
    elif r() < Num.max/i.n: 
      i.old = True
      i._all[int(r()*len(i._all))] = x
    return x

  def all(i):
    if i.old: i._all.sort()
    i.old = False
    return i.old

  def dist(i,x,y):
    if x=="?" : x = i.lo if y > (i.lo + i.hi) / 2 else i.hi
    if y=="?" : y = i.lo if x > (i.lo + i.hi) / 2 else i.hi
    return abs(norm(x, i.lo, i.hi) - norm(y, i.lo, i.hi))

class Sym(Col):
  def __init__(i,**k): 
    super().__init__(**k); i.has = {}
  def add1(i,x): i.has[x] = 1 + i.has.get(x,0); return x
  def dist(i,x,y): return 0 if x==y else 1

class Sample(o):
  def __init__(i,my,keep=True): 
    i.rows,i.cols,i.x,i.y = [],{},{},{}
    i.my,i.keep,i.klass = my,keep,None

  def add(i,lst):
    "Update headers and rows."
    def create(lst):
      for c,s in enumerate(lst):
        k= Col if "?"in s else (Num if s[0].isupper() else Sym)
        new = k(at=c, txt=s)
        i.cols[c] = new  # cols now unempty so, next time, we go to the 'else'
        if "?" not in s:
          if "!" in s: i.klass = new
          (i.y if s[0].isupper() else i.x)[c] = new
    #-----------------------------------
    def update(lst):
      lst = [col.add( lst[col.at] )  for col in i.cols.values()]
      if i.keep:
        i.rows += [Row(i,cells = lst)]
    #-----------------------------------
    (update if i.cols else create)(lst)

  def dist(i,a,b):
    "Aha's distance metric."
    d, n = 0, 1E-32
    for col,x in i.pairs(a, i.x):
      y   = b.cells[col.at]
      inc = 1 if x==y=="?" else col.dist(x, y)
      d  += inc**i.my.p
      n  += 1
    return (d/n)**(1/i.my.p)
  
  def near(i,row1,rows=None, least=inf):
    "return the thing nearest `row1`"
    for row2 in rows or i.rows:
      if id(row1) != id(row2):
        d = i.dist(row1,row2)
        if d < least: least, out = d, row2
    return out

  def far(i,row1,rows=None):
    "From `n` random rows, return the `i.my.far*n`-th row from `r1`"
    rows= rows or i.rows
    some= random.sample(rows,min(128,len(rows)))
    some= sorted([(i.dist(row1,row2),row2) for row2 in some], key=first) 
    return some[ int(i.my.far*len(some)) ]

  def pairs(i,  z, cols={}):
    """iterate across lists or dictionaries, returning items
    and their index (or key). if `cols` is supplied, restrict
    the iteration to `cols`."""
    z = z.cells
    if cols:
      for col in cols.values(): yield col, z[col.at]
    else:
      for j,x in (z.items() if type(z)==dict else enumerate(z)):
        yield i.cols[j],x

  def slurp(i,f):
    "Import from csv file `f`."
    for a in csv(f): i.add(a)
    return i

class Row(o):
  def __init__(i,sample, cells=[]): i.cells,i.sample = cells,sample
  def evaluated(i):
    "Evaluated if the y values are known."
    for col in i.sample.y.values():
      if i.cells[col.at] != "?": return True
    return False

def csv(file, sep=",", dull=r'([\n\t\r ]|#.*)'):
  "read csv files"
  with open(file) as fp:
    for s in fp:
      s=re.sub(dull,"",s)
      if s: yield s.split(sep)

def first(lst):
  "return first item"
  return lst[0]

def norm(x,lo,hi): 
  return 0 if abs(lo-hi)<1E-32 else (x-lo)/(hi-lo)


