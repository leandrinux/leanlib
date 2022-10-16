uses
  xcrt, types, userial, ulog;

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

begin
  initLog;
  while not keypressed do
  begin
    ulog.Log^.out('Hello World!');
    delay(1000);
  end;
end.