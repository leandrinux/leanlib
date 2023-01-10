{
  sets up VGA mode 13h, then displays a custom mouse cursor
  and waits until the right button is clicked. Then it restores
  the text mode and ends.
}

uses
  int10, int33;

begin
  mouseReset;
  if not isMouseAvailable then
  begin
    writeln('Mouse not available');
    exit;
  end;

  setVideoMode($13);

  setGraphicsCursor(C_CURSOR_TRIANGLE);
  showMouseCursor;

  while not mouseButtonDown(C_MOUSE_RIGHT) do;

  hideMouseCursor;

  setVideoMode(3);
end.