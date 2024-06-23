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
  filename := 'demo.asm';
  if filename='' then 
    error('no source file specified')
  else
  begin
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