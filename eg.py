#!/usr/bin/env python3.9
from reason import *
import argparse,traceback

class Eg:
  _all, _crash = {}, -1

  def one(f): 
    "`@Eg.one` : registers a function."
    if f.__name__[0] != "_": Eg._all[f.__name__] = f
    return f

  def _cli(usage,dict):
    a = argparse
    p = a.ArgumentParser(prog=usage, description=__doc__,
                         formatter_class=a.RawTextHelpFormatter)
    used, add  = {}, p.add_argument
    for k, (ako, x, h) in sorted(dict.items()):
      k0 = k[0]
      k0 = k0.upper() if k0 in used else k0
      c = used[k0] = k0  # (3)
      if x == False: add("-"+c, dest=k, default=False, help=h, action="store_true")
      else: add("-"+c, dest=k, default=x,help=h+" [" + str(x) + "]",type=type(x), metavar=k)
    return p.parse_args().__dict__
 
  def _run(my, f):
    random.seed(my.seed)
    try: f(my); print(f"\x1b[1;32m✔ {f.__name__}\x1b[0m") # print green
    except Exception as err:
      Eg._crash += 1
      print(f"\x1b[1;31m✘  {f.__name__}\x1b[0m") # print red
      if my.loud: print(traceback.format_exc())
  
  def run():
    """Eg.run()` : update config with any command-line flags then
    run any todos  (resetting the random number seed  beforehand)."""
    my = o(**Eg._cli("python3.9 eg.py [OPTIONS]",CONFIG))
    if my.Todo: 
      return [print(f"{name:>15} : {f.__doc__ or ''}") 
              for name,f in Eg._all.items()]
    if my.todo == "all":
      for _,f in Eg._all.items(): Eg._run(kopy(my),f)
      print("Errors:", Eg._crash)
      sys.exit(Eg._crash)
    else:
      if my.todo: Eg._run(my, Eg._all[my.todo])

#--------------------------------------------------
eg = Eg.one

@eg  
def fails(my): 
 "test if fails are caught"
 print("Can my test engine catch fails?")
 assert 1/0

@eg
def show(my): 
  "Show default config, updated with any command-line flags"
  print(my)

@eg
def csvs(my):
  for row  in csv("data/auto93.csv"):
    print(row)

@eg
def data(my):
  d= slurp(my,my.file)
  #for row in d.rows: print(row)
  print(d.lo)
  print(d.hi)

@eg
def dists(my):
  data= slurp(my,my.file)
  for row1 in  random.sample(data.rows,10):
    d,row2 = far(data,row1)
    print("")
    print(row1.cells)
    print(row2.cells,int(100*d))

Eg.run()
