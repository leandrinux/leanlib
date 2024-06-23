uses
  ats,
  lcbase,
  lbuilder;

var 
  filename: string;
  builder: PBuilder;

begin
  writeln('LASMC lsystem assembly compiler v', C_LASMC_VERSION);
  writeln('Built ', C_BUILD_DATE, ' at ', C_BUILD_TIME);

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
      setSourceFileStream(filename);
      setStandardMessageOutput;
      build;
      release;
    end;

  end;
end.