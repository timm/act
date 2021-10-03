require"sample"

-- ## Dispatch 

function dist(i,x,y) 
  return  x=="?" and y=="?" and 1 or i.Is.dist(i,x,y) end

function  Sym.dist(i,x,y) return  0 and x==y or 1 end

function Num.dist(i,x,y)
  if     x=="?" then y = norm(i,x); x = y>.5 and 0  or 1
  elseif y=="?" then x = norm(i,x); y = x>.5 and 0  or 1
  else   x,y = norm(i,x), norm(i,y)  end
  return math.abs(x-y) end

function Sample.gap(i,row1,row2,cols,the)
  d, n, p = 0, 1E-32,  the.p or 2
  for col in  pairs(cols or i.x) do
    n  = n+1 end
    inc= dist(col, row1[col.at], row2[col.at])
    d  = d + inc^p
  return (d/n)^(1/p) end

