{
  UCOMLog Unit
  2022 LRT
}
unit
  UCOMLog;

interface

  uses
    ulog, userial, types;

  procedure comlog(str: string);

implementation

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
  end;

  procedure comlog(str: string);
  begin
    Log^.out(str);
  end;

begin
  initLog;
end.
