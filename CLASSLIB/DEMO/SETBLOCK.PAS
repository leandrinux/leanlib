uses
  xcrt, udisplay, ubitmap, ucanvas;

var
  canvas: PCanvas;
  bitmap: PBitmap;

begin
  DisplayAdapter := new(PDisplayAdapter, init);
  DisplayAdapter^.detectAdapter;
  DisplayAdapter^.setVideoMode(0);
  canvas := DisplayAdapter^.getCanvas;
  bitmap := canvas^.getBitmap;

  canvas^.getStrokeBrush^.color := 4;
  canvas^.rect(10, 10, 100, 100);
  readkey;

  canvas^.getStrokeBrush^.color := $F;
  canvas^.getFillBrush^.color := $F;
  canvas^.frect(10, 10, 100, 100);
  readkey;

  bitmap^.setPixelBlock(10, 10, 109, 109, 4);

  readkey;
  DisplayAdapter^.setTextMode;
end.