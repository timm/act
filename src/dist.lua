require"sample"

-- ## Dispatch 

function dist(i,x,y) return x=="?" and y=="?" and 1 or i.Is.dist(i,x,y) end

function  Sym.dist(i,x,y) return  0 and x==y or 1 end

function Num.dist(i,x,y)
  if     x=="?" then y = norm(i,x); x = y>.5 and 0  or 1
  elseif y=="?" then x = norm(i,x); y = x>.5 and 0  or 1
  else   x,y = norm(i,x), norm(i,y)  end
  return math.abs(x-y) end

function gap(i,row1,row2,cols)
  d, n, p = 0, 1E-32,  i.the.p or 2
  for col in  pairs(cols or i.x) do
    n  = n+1 end
    inc= dist(col, row1[col.at], row2[col.at])
    d  = d + inc^p
  return (d/n)^(1/p) end

function gaps(i,row1,rows, cols,   t)
  t={}
  for _,row2 in pairs(rows or i.rows) do 
    t[1+#t] = {gap(i,row1,row2,cols) ,row2} end
  return order(t, function (x,y) return x[1] < y[1] end)


function div(i,rows,         one,two,three,tmp,c,a,b,l,r)
  one = lst.any(rows)
  two = self:faraway(one, the, rows)
  three = self:faraway(two, the, rows)
  c   = self:dist(two, three, the)
  tmp = {}
  for _,row in pairs(rows) do
    a = self:dist(row, two, the)
    b = self:dist(row, three, the)
    tmp[1+#tmp] = {row= row,
                   x  = (a^2 + c^2 - b^2) / (2*c)}
  end
  l,r = {},{}
  for i,rowx in pairs(lst.keysort(tmp,"x")) do
    table.insert( i<=#rows//2 and l or r, rowx.row) end
  return l,r end

function cluster(i,,Sample:divs(the,     out,enough,run,better)
  function run(rows,lvl,      pre,l,r)
    if true or the.loud then  -- very useful debugging aid
      pre = "|.. ";print(pre:rep(lvl)..tostring(#rows))
    end
    if #rows < enough then
      out[#out+1] = self:clone(rows)
    else
      l,r = self:div(rows, the,cols)
      run(l, lvl+1)
      run(r, lvl+1)  end
  end --------------------------------
  out = {}
  enough = 2*(#self.rows)^the.enough
  run(self.rows, 0)
  better = function(t1,t2) return self:better(t1:mid(), t2:mid()) end
  return lst.sort(out, better) end

