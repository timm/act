-- vim: filetype=lua ts=3 sw=3 sts=3  et :

local lib=require("lib")
local Num,Sym,Skip = {},{},{} 

local obj=lib.obj

-- ## Columns

-- All columns know  their column number, column name, 
local function col(at,txt) 
   return {at= at,txt=txt,n=0,
           w = txt:find("-") and -1 or 1} end

-- counter for symbols
function Sym:new(at, name)  
   return obj(self,"Sym",{
      n=0, name=name or "", at=at or 0, has={}, mode=0,_most=0}) end

-- counter for numbers
function Num:new(at,txt) 
   i = isa(self,"Num",col(at,txt))
   i.mu, i.m2,i.sd, i.lo,i.hi = 0,0,0 ,inf, -inf
   return i end

-- If you are not a Sym  or a Num, you  are just a boring old Skip
-- that ignore everything yourself it.
function Skip:new(at, name)  return obj(self,"Skip", col(at,txt)) end

function Sample:new(inits,       new)
   new = obj(self,"Sample",
             {rows={},keep=true,cols={},names={},x={},y={}})
   for _,row in pairs(inits or {}) do new:add(row) end  
   return new end
 
function Sample:add(t)
   if #self.names > 0 then self:data(t) else self:header(t) end end

function Sample:load(file) 
   for row in csv(file) do self:add(row) end 
   return self end
  
function Sample:header(t,   what,new,tmp)
   self.names = t
   for at,name in pairs(t)  do
      what = isWhat(name)
      new  = what:new(at,name) 
      self.cols[1+#self.cols] = new
      if not isSkip(name) then
         tmp= self[isY(name) and  "y" or "x"]
         tmp[ 1+#tmp ] = new
         if isKlass(name) then self.klass = new end end end end
  
function  Sample:clone(inits,    new)
   new = Sample:new():add({self.names})
   for _,row in pairs(inits or {}) do new:add(row) end
   return new end

return {Num=Num,Sym=Sym,Skip=Skip}
