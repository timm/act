import math,argparse,random,functools,traceback
from copy import deepcopy as kopy
sq=math.sqrt

CONFIG = dict(    
  bins = (float,.5,   "min bin size is n**bin"),    
  cohen= (float,.35,  "ignore differences less than cohen*sd"),    
  depth= (int,  5,    "dendogram depth"),     
  end  = (int,  4,    "stopping criteria"),    
  far  = (float,.9,   "where to find far samples"),      
  rule = (str,  "plan","assessment rule for a bin"),
  loud = (bool, False,"loud mode: print stacktrace on error"),    
  max  = (int,  500,  "max samples held  by `Nums`"),     
  p    = (int,  2,    "co-efficient on distance equation"),    
  seed = (int,  10014,  "random number seed"),      
  support=(int, 2,    "use x**support to score a range"),
  todo = (str,  "",   "todo: function (to be run at start-up)"),     
  Todo = (str, False, "list available items for -t"),
  verbose=(str,False, "enable verbose prints")
)     

class o:
  "Return a class can print itself (hiding 'private' keys)"
  def __init__(i, **d)  : i.__dict__.update(d)
  def __getitem__(i, k) : return i.__dict__[k]
  def __repr__(i) : return "{"+ ', '.join(
    [f":{k} {v}" for k, v in i.__dict__.items() if  k[0] != "_"])+"}"

class Col(o):
  "generic columns  stuff"
  def __init__(i,at=0,txt="",init=[]):
    i.at,i.txt,i.n,i.w = at,txt,0, -1 if "-" in txt else 1
    [i + x for x in init]

  def __add__(i,x):
    "only add things that are not `?`"
    if x != "?":
      i.n += 1; i.add(x)

  def __sub__(i,x):
    "only subs things that are not `?`"
    if x != "?":
      i.n -= 1; i.sub(x)

  def add(i,x): ...

  def clone(i):
    "Return something with the same structure, but no data"
    i.__class__(at=i.at, txt=i.txt)

  def sub(i,x): ...

class Num(Col):
  "counter for numbers"
  def __init__(i,*l,**kw):
    i.mu,i.m2,i.sd,i.lo,i.hi = 0,0,0,1E31,-1E31
    super().__init__(*l,**kw)
  

  def add(i, x):
    "increment `mu,sd,lo,hi`"
    d     = x - i.mu
    i.mu += d / i.n
    i.m2 += d * (x - i.mu)
    i.sd  = i.sd()
    if x < i.lo: i.lo = x
    if x > i.hi: i.hi = x
   
  def dist(i,x,y):
    "separation  `x`  and `y`"
    norm = lambda x: 0 if abs(i.hi-i.lo) < 1E-31 else (x-i.lo) / (i.hi-i.lo)
    if x=="?":
      y  = norm(y); x= 0 if y>0.5 else 1
    elif y=="?":
      x = norm(x); y= 0 if x>0.5 else 1
    else:
      x,y = norm(x), norm(y)
    return abs(x-y)

  def sd(i): 
    "return variability around the expected value"
    return 0 if i.m2<0 or i.n<2 else (i.m2/(i.n-1))**.5

  def sub(i,x):
    "decrements `mu,sd,lo,hi`"
    d     = x - i.mu
    i.mu -= d / i.n
    i.m2 -= d * (x - i.mu)
    i.sd  = i.sd()

class Sym(Col):
  "counter for symbols"
  def __init__(i,*l,**kw):
    i.has = {}
    super().__init__(*l,**kw)

  def add(i,x):
    "increment symbol counts"
    if x != "?": i.has[x] = 1 + i.has.get(x,0)

  def dist(i,x,y):
    "separation  `x`  and `y`"
    return 0 if x==y else 1

  def entropy(i): 
    "entropy"
    return -sum(v/i.n*math.log2(v/i.n) for v in d.values())

  def sub(i,x):
    "decrements symbol counts"
    if x != "?": i.has[x] = max(0, i.has.get(x,0) - 1)

class Sample(o):
  "Stores rows, summarizes in columns"
  def __init__(i,my,init=[],keep=True): 
    i.my,i.head,i.rows,i.cols,i.x,i.y,i.keep = my,[],[],[],{},{},keep
    [i + x for x in init]

  def __add__(i,lst):
    if i.cols:
      [col + x for col,x in zip(i.cols,lst)]
      if i.keep:
        i.rows += [lst]
    else:
      i.head = lst
      for c,s in enumerate(lst):
        what = Col if "?" in s else (Num if s[0].isupper() else Sym)
        new = what(c,s)
        i.cols += [new]
        if "?" not in s:
          (i.y if "+" in s or "-" in s or "!" in s else i.x)[c] = new

  def clone(i,init=[]):
    "Return something with the same structure, but no data"
    return Sample(my=i.my, init=[i.head]+init, keep=i.keep)

m = [ 
      [ 1,3, 20, 100, 3, 3, 2, "?", 4, "?", 2], 
      [ 1,3, 23, "?", 3, 3, 2, "?", 4, "?", 2], 
      [10,1, 20, 10, 3, 3, 2, "?", 4, "?", 2],
      [ 1,3, 20, 100, 3, 3, 2, "?", 4, "?", 2], 
      [ 1,3, 40, "?", 3, 3, 2, "?", 4, "?", 2], 
      [10,1, 20, 10, 3, 3, 2, "?", 4, "?", 2]
    ]
for c in range(4):
  print("")
  print(c)

def csv(file, sep=",", dull=r'([\n\t\r ]|#.*)'):
  "read csv files"
  def atom(s):
    try: float(s)
    except Exception: return s
  with open(file) as fp:
    for s in fp:
      s=re.sub(dull,"",s)
      if s: yield [atom(x) for x in s.split(sep)]

def dist(s,xs,ys):
  d,n = 0, 1E-32
  for col,x in pairs(xs,  s.x):
    inc = 1 if x=="?" and y=="?" else col.dist(x, ys[col.at])
    d  += inc**s.my.p
  return (d/n)**(1/s.my.p)

def pairs(x,cols={}):
  if type(x)==dict:
    for k,v in x.items(): yield cols[k],v
  else:
    for _,col in cols.items(): yield col,x[col.at]
    
class Eg:
  all, crash = {}, -1

  def one(f): 
    "Define one example."
    if f.__name__[0] != "_": Eg.all[f.__name__] = f
    return f

  def cli(usage,dict):
    """
    (1) Execute a command-line parse that uses `dict` keys as  command line  flags
        (so expect `dict` values to be tuples (type, defaultValue,help));   
    (2) Define switches for  defaults that re `False`;    
    (3) If keys repeat, make the  second one upper case."""
    p    = argparse.ArgumentParser(prog=usage, description=__doc__, 
                      formatter_class=argparse.RawTextHelpFormatter)
    add  = p.add_argument
    used = {}
    for k, (ako, default, help) in sorted(dict.items()):
      k0 = k[0]
      k0 = k0.upper() if k0 in used else k0
      c = used[k0] = k0  # (3)
      if default == False: # (2)
        add("-"+c, dest=k, default=False, 
            help=help, action="store_true")
      else: # (1)
        add("-"+c, dest=k, default=default, 
            help=help + " [" + str(default) + "]",
            type=type(default), metavar=k)
    return p.parse_args().__dict__

  def run1(my, f):
    """Set seed to a common standard. 
    Run. Increment crash if crash."""
    random.seed(my.seed)
    try: 
      f(my)
      print(f"\x1b[1;32m✔ {f.__name__}\x1b[0m")
    except Exception as err:
      Eg.crash += 1
      print(f"\x1b[1;31m✘  {f.__name__}\x1b[0m")
      if my.loud: print(traceback.format_exc())
  
  def run():
    """(1) Update the config using any command-line settings.
       (2) Maybe, update `todo` from the  command line."""    
    my = o(**Eg.cli("python3.9 eg.py [OPTIONS]",CONFIG))
    if my.Todo: 
      return [print(f"{name:>15} : {f.__doc__ or ''}") 
              for name,f in Eg.all.items()]
    if my.todo == "all":
      for _,f in Eg.all.items():
        my = kopy(my)
        Eg.run1(my,f)
      print("Errors:", Eg.crash)
      sys.exit(Eg.crash)
    else:
      if my.todo:
        Eg.run1(my, Eg.all[my.todo])
