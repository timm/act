#!/usr/bin/env bash
src() { cat<<'EOF' | gawk '{print  gensub(/\.([^0-9\\*\\$\\+])([a-zA-Z0-9_]*)/, 
                                          "[\"\\1\\2\"]","g", $0) }'

func has(i,k) { i.k[0]; delete i.k }
func add(i,x,   f) { f=FUNCTAB[i.is"Add"]; return @f(i,x) }

func Obj(i)      { split("",i,"") }
func Col(i,n,s)  { Obj(i); i.n=n; i.is="Col"; i.txt=s; i.w= s~/-/?-1:1   }
func Num(i,n,s)  { Col(i,n,s);    i.is="Num"; i.n=i.m2=1; has(i,"has")}
func NumAdd(i,x) { print(10*x) }

BEGIN { Num(i) ; add(i,20) }
EOF
}

gawk --source "`src`"