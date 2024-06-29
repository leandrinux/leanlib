uses
  ats,
  lcbase,
  lbuilder;

var 
  filename: string;
  builder: PBuilder;

begin
  write('LASMC lsystem assembly compiler v', C_LASMC_VERSION);
  writeln(' - ', C_BUILD_DATE, ' ', C_BUILD_TIME);
  filename := 'demo1.asm';
  if filename='' then 
  begin
    writeln('no source file specified');
    halt(1);
  end else begin
    builder := new(PBuilder, init);
    with builder^ do
    begin
      setSourceFileStream(filename);
      setStandardMessageOutput;
      build;
      release;
    end;
  end;
end.