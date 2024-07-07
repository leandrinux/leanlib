uses
  ats, strings,
  lcommon, lcbase, lbuilder, ltexts;

const
  C_BUILDER_CONFIG : TBuilderConfig = (
    isVerbose: false
  );

var 
  filename: string;
  builder: PBuilder;

begin
  msg(EMsgStrong, C_STR_BANNER, C_STR_LSYSTEM_VERSION + #0 + C_STR_LSYSTEM_CODENAME);
  msg(EMsgStrong, C_STR_BUILD_TS, C_BUILD_DATE + #0 + C_BUILD_TIME);
  filename := 'examples\demo1';
  if filename='' then 
    msg(EMsgFatal, C_STR_NO_SOURCE_FILE, '')
  else begin
    builder := new(PBuilder, init);
    with builder^ do
    begin
      setSourceFileStream(filename + '.asm');
      setTargetFileStream(filename + '.bin');
      setConfig(C_BUILDER_CONFIG);
      build;
      release;
    end;
  end;
end.