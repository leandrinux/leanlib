uses
  xcrt, types, int10, upoints, ucanvas, uvgadrv, math, debug;

const
  C_ORIGIN_X = 160;
  C_ORIGIN_Y = 40;
  C_MAJOR_RADIUS = 40;
  C_MINOR_RADIUS = 10;

{
  radius circles mseg  delta
  40     1       6            2   116  
  40     2       59    53     3   168  52
  40     3       114   55     4   222  54
  40     4       278   164    5   276  54
  40     5       223   -55    6   332  56
  40     6                        385  53
}

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

function run(const bitmap: PVGAMode13Bitmap; number: byte): longint;
var
  points, p: PPoint;
  i, pointCount, byteSize: word;
  clockA, clockB: longint;
  c: byte;
begin
  delay(1000);
  clockA := dbg_clock;
  Math.createCirclePoints(C_MAJOR_RADIUS, points, pointCount, byteSize);
  p := points;
  for i := 1 to pointCount do
    with bitmap^, p^ do
    begin
      c := number;
      while c > 0 do
      begin
        setPixel((c shl 3) + C_ORIGIN_X + x, (number shl 4) + C_ORIGIN_Y + y, c);
        dec(c);
      end;
      inc(p);
    end;
  freemem(points, byteSize);  
  clockB := dbg_clock;

  run := clockB - clockA;
end;


const 
  C_ITERATIONS = 6;

var
  canvas: PCanvas;
  bitmap: PVGAMode13Bitmap;
  baseTime, currentTime, diff: longint;
  i: byte;
  data: array[0..C_ITERATIONS-1] of longint;

begin
  SetVideoMode(C_VIDMODE_VGA_320x200_256);
  bitmap := new(PVGAMode13Bitmap, init);

  i := 0;
  while i<C_ITERATIONS do
  begin
    data[i] := run(bitmap, i+1);
    inc(i);
  end;
  bitmap^.release;

  SetVideoMode(C_VIDMODE_CGA_T_80x25_16);
  i := 0;
  while i < C_ITERATIONS do
  begin
    write('#', i+1);
    write(#9, data[i]);
    if i>0 then write(#9, data[i] - data[i-1]);
    writeln;
    inc(i);
  end;

  readkey;
end.