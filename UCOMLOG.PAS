{
  UCOMLog Unit
  2022 LRT
}
unit
  UCOMLog;

interface

  uses
    ulog, userial, types, test;

  procedure log(str: string);

implementation

  procedure log(str: string);
  begin
    ulog.Log^.out(str);
  end;
  
  procedure logWrite(s: string); far;
  begin
    log(s);
  end;

  procedure initLog;
  var
    com: PSerial;
    log: PLog;
  begin
    com := new(PSerial, initWithPort(COM2));
    log := new(PLog, initWithStream(com));
    log^.setAsDefault;
    log^.release;
    com^.release;
    setTestWriteProc(logWrite);
  end;

begin
  initLog;
  log('Log started.');
end.
