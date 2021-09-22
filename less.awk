#!/usr/bin/env bash
src() { cat<<'EOF' | gawk '{print  gensub(/\.([^0-9\\*\\$\\+])([a-zA-Z0-9_]*)/, 
                                          "[\"\\1\\2\"]","g", $0) }'

function has(i,k) { i.k[0]; delete i.k }
function add(i,x,   f) { f=FUNCTAB[i.is"Add"]; return @f(i,x) }

function Obj(i)      { split("",i,"") }
function Col(i,n,s)  { Obj(i); i.n=n; i.is="Col"; i.txt=s; i.w= s~/-/?-1:1   }
function Num(i,n,s)  { Col(i,n,s);    i.is="Num"; i.n=i.m2=1; has(i,"has")}
function NumAdd(i,x) { print(10*x) }

BEGIN { Num(i) ; add(i,20) }
EOF
}

gawk --source "`src`"
