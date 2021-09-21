import math,argparse,functools
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
  def __init__(i,at,txt,init=[]):
    i.at,i.txt,i.n,i.w = at,txt,0,-1 if "-" in txt else 1
    [i + x for x in init]

  def __add__(i,x):
    "only add things that are not `?`"
    if x != "?":
      i.n += 1; i.add(x)

  def __sub__(i,x):
    "only subs things that are not `?`"
    if x != "?":
      i.n -= 1; i.sub(x)

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
    i.sd  = 0 if i.m2<0 else (0 if i.n<2 else ((i.m2/(i.n-1))**.5))
    if x < i.lo: i.lo = x
    if x > i.hi: i.hi = x

  def sub(i, x):
    "decrement `mu,sd,lo,hi`"
    d     = x - i.mu
    i.mu -= d / i.n
    i.m2 -= d * (x - i.mu)
    i.sd  = 0 if i.m2<0 else (0 if i.n<2 else ((i.m2/(i.n-1))**.5))

class Sym(Col):
  "counter for symbols"
  def __init__(i,*l,**kw):
    i.has = {}
    super().__init__(*l,**kw)

  def add(i,x):
    "increment symbol counts"
    if x != "?": i.has[x] = 1 + i.has.get(x,0)

  def sub(i,x):
    "decrement symbol counts"
    if x != "?": i.has[x] = max(0, i.has.get(x,0) - 1)

def csv(file, sep=",", dull=r'([\n\t\r ]|#.*)'):
  "read csv files"
  def atom(s):
    try: float(s)
    except Exception: return s
  with open(file) as fp:
    for s in fp:
      s=re.sub(dull,"",s)
      if s: yield [atom(x) for x in s.split(sep)]



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
