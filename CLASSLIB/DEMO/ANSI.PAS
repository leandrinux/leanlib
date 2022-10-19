uses
  xcrt, userial, types, uansiw;

var
  ser: PSerial;
  ansi: PAnsiWriter;

begin
  ser := new(PSerial, initWithPort(COM2));
  ansi := new(PAnsiWriter, initWithStream(ser));
  ser^.release;

  with ansi^ do
  begin
    setcolor(bgBlue);
    clear;
    hidecursor;
    gotoxy(1,1);
    move(right, 5);
    setcolor(bgBlack);
    setcolor(fgMagenta);
    setcolor(bold);
    writestr('Hello ');
    setcolor(none);
    setcolor(bgWhite);
    setcolor(fgMagenta);
    move(down, 2);
    writestr('world');
    release;
  end;
end.