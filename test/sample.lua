package.path = '../src/?.lua'
local Sample=require"sample"
srand()

local som=Sample.Some:new(32) 
for _ = 1,10^6 do som:add(1000*rand()//1) end
shout(som:has())

-- local s = Sample:new( "../data/auto93.csv")
-- for _,v in pairs(s.cols) do print("has",show(v)) end
-- assert(s.cols[1].hi==8)
-- assert(s.cols[3].n==392)
-- print(mid(s.cols[2]), spread( s.cols[2]))
-- shop(mid(s))
-- shop(mid(s,s.y))
