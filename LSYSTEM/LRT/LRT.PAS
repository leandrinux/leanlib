uses
  lsystem;

var
  lsystem: PSystem;

begin
  lsystem := new(PSystem, init);
  lsystem^.loadBinaryFile('..\examples\demo1.bin');
  lsystem^.release;
end.