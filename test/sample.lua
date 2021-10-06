package.path = '../src/?.lua'
local sys=require"sample"

local som=sys.Some(32) 
som:add(100)


local sym=sys.Sym()
for i=1,10 do
  sym:add("a")
  sym:add("b") end
assert(1==sym:spread())

local num=sys.Num()
print(1,num)
-- for _ = 1,100 do
--   for _,v in pairs{1, 3, 5, 7} do
--     num:add(v) end end
-- local s= num:spread()
-- assert(s>2.36 and s < 2.37)
-- print(2,num)
-- --
--
-- local the = about()
-- local s = sys.Sample(the, "../data/auto93.csv")
-- print(#s.cols)
-- -- for _,v in pairs(s.cols) do print("has",out(v)) end
-- -- assert(s.cols[1].hi==8)
-- assert(s.cols[3].n==392)
-- print(mid(s.cols[2]), spread( s.cols[2]))
-- shop(mid(s))
-- shop(mid(s,s.y))
