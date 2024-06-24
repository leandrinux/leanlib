{ 
  TPBUILD simplifies the task of building programs using the 
  Turbo Pascal v7 compiler by adding support of packages and the 
  ability to build apps without rebuilding the entire project

  You simply write your code normally in a directory and you run TPBUILD
  with no parameters to start. TPBUILD reads the build.txt file and knows
  what units or packages should be built or included.

  TPBUILD also generates a new unit at build time including data such as
  the build date and time which are unsupported by the compiler

  The purpose of TPBUILD is not just to build a program but do it easily,
  fast, and with descriptive messages. 
}
{$M $4000,0,0 }

uses
  tpstring,
  tpunit;

begin
  writeln(C_STR_WELCOME);
  if getTPCPath <> '' then 
    log(C_STR_TPC_LOCATION + getTPCPath)
  else 
    error(C_STR_TPC_NOT_INSTALLED);
  buildAll('example');
end.