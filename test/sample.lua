package.path = '../src/?.lua'
require"sample"
local s = fromFile(Sample.new(), "../data/auto93.csv")
for _,v in pairs(s.cols) do print("has",show(v)) end
assert(s.cols[1].hi==8)
assert(s.cols[3].n==392)
print(mid(s.cols[2]), spread( s.cols[2]))
shop(mid(s),ys(s))

