unit test;

interface

  uses
    xcrt, utils;

  type
    TTestProc = function (obj: pointer): boolean;
    TTestWrite = procedure(s: string);
    
  procedure setTestWriteProc(p: TTestWrite);
  procedure measure(name: string; proc: TTestProc; obj: pointer; times: word); 

implementation

  var
    testWrite: TTestWrite;  

  procedure setTestWriteProc(p: TTestWrite);
  begin
    testWrite := p;
  end;

  procedure defaultWrite(s: string); far;
  begin
    writeln(s);
  end;

  procedure measure(name: string; proc: TTestProc; obj: pointer; times: word);
  var
    i: word;
    ticks: longint;
  begin
    testWrite('start measure ' + name + ' (' + inttostr(times) + ' times)');
    i := times;
    ticks := C_TICKS^;
    while (i>0) and proc(obj) do dec(i);
    ticks := (C_TICKS^ - ticks) div times;
    testWrite('ended measure ' + name + ': ' +longtostr(trunc(ticks * C_TICK_DURATION)) + 'ms');
  end;

begin
  setTestWriteProc(defaultWrite);
end.