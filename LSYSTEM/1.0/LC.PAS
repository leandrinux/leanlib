uses
  ats,
  lcbase,
  lbuilder;

const
  C_BUILDER_CONFIG : TBuilderConfig = (
    isVerbose: false
  );

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
      setConfig(C_BUILDER_CONFIG);
      build;
      release;
    end;
  end;
end.