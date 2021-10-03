package.path = '../src/?.lua'
require"sample"
local s=load(Sample.new(), "../data/auto93.csv")
