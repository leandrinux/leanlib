uses
  xcrt,
  udisplay, utrender, usysfont;

var
  tr: PTextRenderer;

begin
  DisplayAdapter^.setVideoMode(0);

  tr := new(PTextRenderer, init);
  tr^.setCanvas(DisplayAdapter^.getCanvas);
  tr^.setFont(SystemFont);
  tr^.write('Hello World');
  tr^.release;

  readkey;
  DisplayAdapter^.setTextMode;
end.