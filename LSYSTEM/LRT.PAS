uses
  lcommon,
  lrtlib;

begin
  writeln('lrt - lsystem runtime version ', C_SYSTEM_VERSION);
  if paramCount <> 1 then
  begin 
    writeln('USAGE: lrt <file.asm>');
    halt(1);
  end;
  runFile(paramStr(1));
end.