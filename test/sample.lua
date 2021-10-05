package.path = '../src/?.lua'
local sys=require"sample"
srand(1)
print(rand(),rand(), rand())

print(sys.Some.__call)
local som=sys.Some(32) 
print(som)
som:add(100)


local sym=sys.Sym()
sym:add("a"); sym:add("sba")
print(sym:spread())
--
-- for _ = 1,10^6 do som:add(randi(1000)) end
-- shout(som:has())
-- shout(som:per(.2))
-- --
-- local sym=Sample.Sym:new()
-- for _ = 1,10^6 do sym:add(randi(10)) end
-- shout(sym)


-- local s = Sample:new( "../data/auto93.csv")
-- for _,v in pairs(s.cols) do print("has",show(v)) end
-- assert(s.cols[1].hi==8)
-- assert(s.cols[3].n==392)
-- print(mid(s.cols[2]), spread( s.cols[2]))
-- shop(mid(s))
-- shop(mid(s,s.y))
