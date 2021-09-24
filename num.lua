-- # class Num
-- |**Does** | 1      |: incrementally maintain in numeric counts|
-- |----     |-------:|------------------------------------------|
-- |         | 2      |: know the mean and standard deviation|
-- |         | 3      |: support inference; e.g. distance, likelihood|
-- |**Has**  | n      |: counter of things seen so far|
-- |         | at     |: column index|
-- |         | name   |: column name|
-- |         | mu     |: mean seen so far|
-- |         | lo     |: smallest number seen so far|
-- |         | hi     |: largest number  seen so far|
-- |         | sd     |: standard deviation|
-- |         | some   |: stores a sample of the symbols|
-- |         | w      |: (for minimize) and  1 (for maximize)|
-- |         | _m2    |: incrementally 2nd moment (internal)|
-- |**Uses** |        |: [Some](some.html)|   
local Num  = {}
local Some = require"some"
local obj  = require"obj"
local _=require("list"); local copy=_.copy

-- --------
-- ## Creation
-- **new(?at : int=0, ?name : str="") : Num**    
function Num:new(at, name)
   name= name or ""
   return obj(self,"Num",
      {some=Some:new(), name=name or "",at=at or 0, 
      n=0, mu=0, _m2=0, sd=0,
      lo= 1E32, hi= -1E32,
      w=name:find("-") and -1 or 1}) end

-- -----
-- ## Update
-- **add(x : num)**    
function Num:add(x,      d)
   if x ~= "?" then
      self.some:add(x)
      self.n   = self.n + 1
      d          = x - self.mu
      self.mu = self.mu + d/self.n
      self._m2 = self._m2 + d*(x - self.mu)
      self.sd = (self._m2<0 or self.n<2) and 0 or (
                     (self._m2/(self.n-1))^0.5)
      self.lo = math.min(x, self.lo)
      self.hi = math.max(x, self.hi)   end end

-- -------
-- ## Comparison
-- **delta(other : Num) : num**   
-- Return the difference in the means, mediated by the variances.
function Num:delta(other,      y,z,e)
   e, y, z = 1E-32, self, other
   return math.abs(y.mu - z.mu) / (
             (e + y.sd^2/y.n + z.sd^2/z.n)^.5) end

-- ----------
-- ## Distance
-- **dist(x : num, y : num) : num**   
-- Implements Aha's instance-based distance algorithm (for numeric attributes);
-- see [section 2.4](https://link.springer.com/content/pdf/10.1007/BF00153759.pdf).
-- In summary, If any value missing, guess a value of the other that
-- maximizes the distance.
function Num:dist(x,y)
   if       x=="?" then y=self:norm(y); x = y>.5 and 0 or 1 
   elseif y=="?" then x=self:norm(x); y = x>.5 and 0 or 1 
   else                      x,y = self:norm(x), self:norm(y) end
   return math.abs(x-y) end

-- ------
-- ## Copy
-- **merge(lst : num+) : Num**    
-- Combine self with   a `lst` of other `Num`s.
function Num:merge(lst,         new)
   new = copy(self)
   for _,x in pairs(lst._all) do new:add(x) end
   return new end

-- -----
-- ## Query
-- **mid() : num**   
-- Central tendency.
function Num:mid() 
   return self.mu end 

-- **norm(x : num) : num**   
-- Return `x` mapped into 0..1 for lo..hi.
function Num:norm(x,      a)
   if x =="?" then return x end
   return (x-self.lo) / (self.hi - self.lo + 1E-32) end

-- **var() : num**      
-- Variance   of numerics   is the   standard deviation.
function Num:var() return self.sd end

-- -------
-- ## Printing
-- **tile(width : int, ps : float+) : table**    
-- For all the `Nums` in `t`, print out normalized
-- in the `lo`..`hi` range of `self`.
function Num:tile(t,width,ps,      a,s,where)
   a = self.some:all()
   s = {}
   for i = 1, (width or 32) do s[i]=" " end
   where = function(n) return math.floor(width*self:norm(n)) end
   pos    = function(p) return a[1] + p*(a[#a] - a[1]) end
   for p=.1,.3,.01 do s[where(pos(p))] ="-" end 
   for p=.7,.9,.01 do s[where(pos(p))] ="-" end 
   s[where(self.some:mid())] = "|"
   return {rank= self.rank or 0,
           str = table.concat(s), 
           mid = per(self.some:all()),
           per = map(ps or {.25, .5, .75}, 
                    function (p) return per(self:all(),p) end)} end

-- --------
return Num
