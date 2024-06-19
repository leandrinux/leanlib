uses
  lbuilder;

var 
  filename: string;
  builder: PBuilder;

begin
  writeln('lsystem compiler');
  { if paramCount=1 then filename := paramStr(1); }
  filename := 'demo.asm';
  if filename='' then 
    writeln('no source file specified')
  else
  begin
  {
    lcu.verbose := true;
    startBuild(filename);
  }
    builder := new(PBuilder, init);
    with builder^ do
    begin
      setDelegate := self;
      setSourceFromFile(filename);
      build;
      release;
    end;

  end;
end.