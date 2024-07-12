uses
  lsystem;

var
  sys: PSystem;

begin
  sys := new(PSystem, init);
  sys^.loadBinaryFile('..\examples\demo1.bin');
  sys^.release;
end.