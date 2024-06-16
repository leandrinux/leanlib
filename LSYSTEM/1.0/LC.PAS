uses
  lcu;

var 
  filename: string;

begin
  writeln('lsystem compiler');
  { if paramCount=1 then filename := paramStr(1); }
  filename := 'demo.asm';
  if filename='' then 
    writeln('no source file specified')
  else
    startBuild(filename);
end.