local seen={}
return function (file,    f,n,src)
  file=file..".lua"
  if not seen[file] then 
    n,t,f = 0,{},io.open(file, "r")
    for line in f:lines() do
      n = n+1
      if n==1 then line = "-- "..line end
      if     line:sub(1,6)="```lua" 
      then   line,codep="", true 
      elseif line:sub(1,3)="```" 
      then   line,codep="", false
      end
      line = codep and line or ("-- ",line) 
      table.insert(t, line) end
    io.close(f)
    seen[file]=load(table.concat(t,"\n"))() end 
  return seen[file] end 
