-- vim: filetype=lua ts=3 sw=3 sts=3  et :

return {
   synopsis = [[
          _   _
         (q\_/p)    rat
          /. .\     (c) Tim Menzies, 2021, unlicense.org
    __   =\_t_/=    
      )   /   \     Bayesian semi-supervised multi-objective
     (   ((   ))    stakeholder-based rule generation.
      \  /\) (/\
   jgs `-\  Y  /
          nn^nn
    ]],
    usage    = "./rat",
    author   = "Tim Menzies",
    copyright= "(c) Tim Menzies, 2021, unlicense.org",
    options  = function () return {
       far=  { .9    ,'Where to look for far things'},
       loud= {false  ,'Set verbose'},
       p=      {2    ,'Distance calculation exponent'},
       samples={256  ,"number of neighbors to explore"},
       seed= {10013  ,'Seed for random numbers'},
       todo= {"hello",'startup action'},
       wild= {false  ,'Run egs, no protection (wild mode)'}} end }

