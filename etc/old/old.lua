function sample:clone(inits) 
  out = sample:new()
  out:add(self.head)
  for _,row in paris(inits or {}) do out:add(row) end
  return out end

function map(t,f,     b)
  b={}; for i,v in pairs(t) do b[i]=f(v) end 
  return b end 

function with(t,f,   b)
  b={}; for i,v in pairs(t) do if f(v) then b[i]=f(v) end end
  return b end 

function without(t,f) return with(t,function(v) return not f(v) end) end


