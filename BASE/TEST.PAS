unit test;

interface

  uses
    xcrt;

  type
    TTestProc = function (obj: pointer): boolean;
    
  procedure measure(name: string; proc: TTestProc; obj: pointer; times: word); 

implementation

  procedure measure(name: string; proc: TTestProc; obj: pointer; times: word);
  var
    ticks: longint;
  begin
    write('measuring ', name);
    ticks := C_TICKS^;
    while (times>0) and proc(obj) do
    begin
      write('.');
      dec(times);
    end;
    ticks := C_TICKS^ - ticks;

    writeln((ticks * C_TICK_DURATION):0:4, 'ms');
  end;

end.