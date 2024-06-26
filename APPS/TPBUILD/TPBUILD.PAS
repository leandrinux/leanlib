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

  Features:

  * builds programs
  * places binaries in a specific folder
  * spanish and english support

  Future features:

  * only builds the units that have been modified since last build
  * a file called build.cfg contains info for the project. For instance
    * what 'packages' (directories) must be included
    * whether it should recompile everything always or not
    * what files must be built
    * where the build binaries must be generated
  * treates directories as packages

}
{$M $4000,0,0}

uses
  {$IFDEF Spanish}tpstr_es,
  {$ELSE}tpstr_en,{$ENDIF}
  tpunit,
  tptpc, 
  tputil;

const
  C_VERSION = '0.2';

begin
  writeln(strformat(C_STR_WELCOME, C_VERSION));
  if TPC_PATH = '' then error(C_STR_TPC_NOT_INSTALLED);
  log(C_STR_TPC_LOCATION + TPC_PATH);
  buildAll('example');
end.