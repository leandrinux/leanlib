uses
  lcommon, lbin;

begin
  writeln('lbuild version ', C_SYSTEM_VERSION);
  
  if paramCount <> 2 then
  begin
    writeln('> wrong arguments');
    writeln('> USAGE: lbuild source.asm binary.bin');
    halt(1);
  end;

  if build(paramStr(1), paramStr(2)) then
    writeln('> build SUCCESSFUL')
  else begin
   writeln('> build FAILED - binary code contains error');
   halt(1);
  end;

end.