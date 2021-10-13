function max(x,y) { return x>y ?    x : y }
function min(x,y) { return x<y ?    x : y }
function abs(x)   { return x<0 ? -1*x : x}

BEGIN {FS=","}
NR==1 {for(c=1;c<=NF;c++) {
         if ($c ~ /\+/) w[c]=1
         if ($c ~ /\-/) w[c]=-1 }
       for(c in  w) {
         lo[c] =  1E32
         hi[c] = -1E32 }}
NR>1  {for(c=1;c<=NF;c++) {
         x = 0+$c
         r[NR-1][c] = x==$c ? x : $c 
         if (c in w) {
           lo[c] = min(lo[c],x)
           hi[c] = max(hi[c],x) }}}
END { asort(r,"compare") }

function compare(_,x,_,y) { return better(x,y) ? -1 : (same(x,y) ? 0 : 1) }

function same(i,j ) {
  for(c in w) if (i[c] != j[c]) return 0
  return 1 }

function better(i,j,     e,n,c,x,y,sum1,sum2) {
  e = 2.71828
  n = length(w)
  for(c in w) {
    x     = norm(i[c], lo[c], hi[c])
    x     = norm(j[c], lo[c], hi[c])
    sum1 -= e ^ ( w[c]* (x - y)/n )
    sum2 -= e ^ ( w[c]* (y - x)/n ) }
 return sum1/n < sum2/n }

function norm(x,lo,hi) { return (abs(lo - hi)<1E-6) ? 0 : (x-lo)/(hi-lo)}
function zitler

  
