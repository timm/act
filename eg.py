#!/usr/bin/env python3.9
from evenless import *
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
def num(my):
  "report sd of some numbers"
  n=Num(init=[9,2,5,4,12,7,8,11,9,3,7,
              4,12,5,4,10,9,6,9,4])
  assert int(100*n.sd) == 306
  assert n.mu  == 7

@eg
def sym(my):
  "report entropy of some symbols"
  s=Sym(init="yyyyyyyyynnnnn")
  assert int(100*ent(s.has)) == 94 

Eg.run()
