uses
  ats, lcommon, lsystem, ltexts;

var
  sys: PSystem;

const
  filename = '..\examples\demo1.bin';

begin
  msg(EMsgStrong, C_STR_BANNER, C_STR_LSYSTEM_VERSION + #0 + C_STR_LSYSTEM_CODENAME);
  msg(EMsgStrong, C_STR_BUILD_TS, C_BUILD_DATE + #0 + C_BUILD_TIME);
  msg(EMsgNormal, C_STR_LOADING_BINARY, filename);
  sys := new(PSystem, init);
  sys^.loadBinaryFile(filename);
  msg(EMsgNormal, C_STR_NOW_RUNNING, '');
  sys^.run;
  sys^.release;
end.