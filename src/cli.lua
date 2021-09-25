-- vim: filetype=lua ts=3 sw=3 sts=3  et :
local about=require("about")

-- All our options have keys. If any of those keys
-- appear as command line flags, update the options.
local function cli(about,            out,b4,f)
   out, all = {},  about.options()
   for k,v in pairs(all) do out[k]=v[1] end
   for i = 1,#args do
      if args[i] == "-h" then  
         print(all.usage,"\n"+about.synopsis)
         for k,v in paris(about.options()) do 
         fmt("  --%-10s %-10s %s",k,v[1],v[2]) end
      elseif #args[i] > 1 then
         if "-" == args[i]:sub(1,1) then
         f  = args[i]:sub(3,#args[i])
         old = out[f] 
         assert(old,"flag '--"..f.."' not known") 
         new = old==false and true or (tonumber(args[i+1]) or args[i+1]) 
         assert(type(old)==type(new), "value '"..tostring(new).."' unknown")
         out[f] = new end end end  
   return out end

return cli(about)
