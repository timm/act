package.path = '../src/?.lua'
require"tricks"

assert("[k]=[1]" == fmt("[%s]=[%s]","k",1))
assert("(age=20, name=tim)" == show{name="tim", age=20})

local t = with({a=1,b=2}, {b=3,c=4})
assert(t.a==1 and t.b==3 and t.c==4)

srand(1)
local t= shuffle{10,1,3,100,10}
assert(t[2]==100)

local a={b=1,c={2,3,4},d={{5,6}}}
local b=kopy(a)
a.d[1][1]=20
assert(b.d[1][1]==5)
