uses
  lcu;

var 
  filename: string;

begin
  if paramCount=1 then filename := paramStr(1);
  
  filename := 'demo.asm';

  writeln('lsystem compiler');
  if filename='' then error('no source file specified');
  initBuild(filename);
  startBuilding;
end.