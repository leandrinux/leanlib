uses
  xcrt, types, int10, upoints, ucanvas, uvgadrv, debug;

const
  C_ORIGIN_X = 160;
  C_ORIGIN_Y = 100;
  C_MAJOR_RADIUS = 80;
  C_MINOR_RADIUS = 10;

procedure plot(canvas: PCanvas; points: PPoints);
var
  point: PPoint;
  count: word;
begin
  points^.get(point, count);
  while count>0 do
  begin
    with canvas^, point^ do
    begin
      getStrokeBrush^.color := random(255);
      circle(x, y, C_MINOR_RADIUS);
    end;
    inc(point);
    dec(count);
  end;
end;

var
  canvas: PCanvas;
  points: PPoints;
  bitmap: PVGAMode13Bitmap;
  clockA, clockB: longint;
begin
  SetVideoMode(C_VIDMODE_VGA_320x200_256);
  bitmap := new(PVGAMode13Bitmap, init);
  canvas := new(PCanvas, initWithBitmap(bitmap));
  points := canvas^.createCirclePoints(C_ORIGIN_X, C_ORIGIN_Y, C_MAJOR_RADIUS);
  clockA := dbg_clock;
  plot(canvas, points);
  clockB := dbg_clock;
  readkey;
  canvas^.release;
  points^.release;
  bitmap^.release;
  SetVideoMode(C_VIDMODE_CGA_T_80x25_16);
  writeln('Time (msec):', clockB - clockA);
  readkey;
end.