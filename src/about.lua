-- ## Config Options
require"tricks"

function about() return {
  seed=   cli( "S",   10014, 'Seed for random numbers'),
  help=   cli( "h",   false, 'show  help'),
  loud=   cli( "l",   false, 'set verbose'),
  dist= {
    far=  cli( "f",      .9, 'where to look for far things'),
    p=    cli( "p",       2, 'distance calculation exponent'),
    some= cli( "s",     128, 'number of neighbors to explore')},
  eg= {
    todo= cli( "t", "hello", 'startup action'),
    wild= cli( "w",   false, 'run egs, no protection (wild mode)')}
} end
