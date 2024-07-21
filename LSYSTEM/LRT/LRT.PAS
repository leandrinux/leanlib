uses
  ats, lcommon, lsystem, ltexts;

var
  sys: PSystem;

const
  isSilent = false;

var
  filename: string;

begin
  if not isSilent then
  begin
    msg(EMsgStrong, C_STR_BANNER, C_STR_LSYSTEM_VERSION + #0 + C_STR_LSYSTEM_CODENAME);
    msg(EMsgStrong, C_STR_BUILD_TS, C_BUILD_DATE + #0 + C_BUILD_TIME);
  end;

  filename := paramstr(1);
  if (length(filename)>0) and (pos('.', filename) = 0) then filename := filename + '.bin';
  if filename='' then msg(EMsgFatal, C_STR_BINARY_NOT_SPECIFIED, '');

  msg(EMsgNormal, C_STR_LOADING_BINARY, filename);
  sys := new(PSystem, init);
  sys^.loadBinaryFile(filename);
  if not isSilent then msg(EMsgNormal, C_STR_NOW_RUNNING, '');
  sys^.run;
  sys^.release;
end.