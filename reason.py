import re,math,random,functools

CONFIG = dict(    
  far  = (float,0.9, "how far to reach for 'distant' examples"),
  file = (str, "data/auto93.csv", "input data file"),
  loud = (bool, False,"loud mode: print stacktrace on error"),    
  p    = (int,  2,    "co-efficient on distance equation"),    
  samples=(int,128,    "number of samples used when finding far items"),
  seed = (int,  10014,  "random number seed"),      
  todo = (str,  "",   "todo: function (to be run at start-up)"),     
  Todo = (str, False, "list available items for -t"))     

def Data(my): return o(my=my,lo={}, hi={}, x={}, y={},rows=[], w={}, head=[])
def Row(cells=[]): return o(cells=cells, used=False)

def add(i,a): 
  (_update if i.lo else _create)(i,a)

def _create(i,a):
  skip   = lambda s: "?" in s
  less   = lambda s: "-" in s
  num    = lambda s: s[0].isupper()
  goal   = lambda s: "!" in s or "+" in s or "-" in s
  i.head = a
  for c,s in enumerate(a):
    if skip(s): continue
    i.w[c] = -1 if less(s) else 1
    (i.y if goal(s) else i.x)[c]=c
    if num(s): i.lo[c], i.hi[c] = 1E21,-1E21

def _update(i,a):
  for c in i.lo: 
    z = a[c]
    if z=="?": continue
    a[c]    = z = float(z)
    i.lo[c] = min(z, i.lo[c])
    i.hi[c] = max(z, i.hi[c])
  i.rows += [Row(cells=a)]

def dist(i,a,b):
  "Aha's distance metric."
  d, n = 0, 1E-32
  for c,x in pairs(a.cells, i.x):
    d += _dist1(i, c, x, b.cells[c])**i.my.p
    n += 1
  return (d/n)**(1/i.my.p)

def _dist1(i,c,x,y):
  if   x==y=="?": return 1
  elif c in i.lo:
    lo, hi = i.lo[c], i.hi[c]
    if   x=="?" : y,x = _xy(y,lo,hi)
    elif y=="?" : x,y = _xy(x,lo,hi)
    else        : x,y = _norm(x,lo,hi), _norm(y,lo,hi)
    return abs(x-y)
  else:
    return 0 if x==y else 1

def _norm(x,lo,hi): 
  return 0 if abs(lo-hi)<1E-32 else (x-lo)/(hi-lo)

def _xy(x,lo,hi): 
  x = _norm(x,lo,hi)
  return x, (0 if x>.5 else 1)

def far(i,row1,rows=None):
  """for `my.samples` selections from `rows`, sort the distance
  and return the item `my.far`-th to maximum distance"""
  rows = rows or i.rows
  rows = random.sample(rows, min(len(rows), i.my.samples))
  rows = sorted([(dist(i,row1,row2),row2) for row2 in rows], key=first)
  return rows[int(i.my.far*len(rows))]

def slurp(my,f):
  i = Data(my)
  for a in csv(f): add(i,a)
  return i

#----------------------------------------------------------
class o:
  "return a class can print itself (hiding 'private' keys)"
  def __init__(i, **d)  : i.__dict__.update(d)
  def __repr__(i) : return "{"+ ', '.join([
    f":{k} {v}" for k, v in i.__dict__.items() if  k[0] != "_"])+"}"

def csv(file, sep=",", dull=r'([\n\t\r ]|#.*)'):
  "read csv files"
  with open(file) as fp:
    for s in fp:
      s=re.sub(dull,"",s)
      if s: 
        yield s.split(sep)

def first(a):
  "return first item"
  return a[0]

def pairs(z, cols={}):
  """iterate across lists or dictionaries, returning items
  and their index (or key). if `cols` is supplied, restrict
  the iteration to `cols`."""
  if cols:
    for c in cols: yield c, z[c]
  else:
    for c,x in (z.items() if type(z)==dict else enumerate(z)):
      yield c,x
