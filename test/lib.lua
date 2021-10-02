local lib=require"lib"
local fmt,show,with,shuffle = lib.fmt,lib.show,lib.with,lib.shuffle
local srand = lib.srand

assert("[k]=[1]" == fmt("[%s]=[%s]","k",1))
assert("(age=20, name=tim)" == show{name="tim", age=20})

local t = with({a=1,b=2}, {b=3,c=4})
assert(t.a==1 and t.b==3 and t.c==4)

srand(1)
print(show(shuffle{10,1,3,100,10}))
