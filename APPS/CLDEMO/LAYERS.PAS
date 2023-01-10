uses
  xcrt, types, consts, udisplay, ubitmap, ufstream, ubmpfile, ubmstack, ubmlayer,
  usbitmap, utils, ubitmap8;

const
  C_FILE = 'c:\res\sprites.bmp';
  C_GRADIENT_W = 100;
  C_GRADIENT_H = 80;

type
  TMovingShape = record
    incX, incY: shortint;
    x, y, w, h: word;
    layer: PBitmapLayer;
  end;

function loadBitmap(filename: string): PBitmap;
var
  fs: PFileStream;
  bmp: PBMPFile;
begin
  fs := new(PFileStream, initWithPath(filename, EFileReadOnly));
  bmp := new(PBMPFile, initWithStream(fs));
  loadBitmap := bmp^.getBitmap;
  fs^.release;
end;

function createLayer(bitmap: PBitmap; x, y, w, h: word; transparent: TColor): PBitmapLayer;
var
  subbm: PSubBitmap;
  bm: PBitmap8;
  layer: PBitmapLayer;
begin
  subbm := new(PSubBitmap, initWithBitmap(bitmap, w, h));
  subbm^.move(x, y);
{
  bm := new(PBitmap8, initWithSize(w, h));
  bm^.merge(subbm, 0, 0);
  layer := new(PBitmapLayer, initWithBitmap(bm));
}
  layer := new(PBitmapLayer, initWithBitmap(subbm));
  layer^.setTransparent(true, transparent);
  bm^.release;
  subbm^.release;
  createLayer := layer;
end;

procedure initMovingShape(var movingShape: TMovingShape; layer: PBitmapLayer);
var
  bitmap: PBitmap;
begin
  bitmap := layer^.getBitmap;
  movingShape.layer := layer;
  with movingShape do
  begin
    w := bitmap^.getWidth;
    h := bitmap^.getHeight;
    x := 1+random(C_GRADIENT_W-w-1);
    y := 1+random(C_GRADIENT_H-h-1);
    incX := random(3)-1;
    incY := random(3)-1;
  end;
end;

procedure moveShape(var movingShape: TMovingShape);
begin
  with movingShape do
  begin
    if (x=0) or (x+w>=C_GRADIENT_W) then incX := -incX;
    if (y=0) or (y+h>=C_GRADIENT_H) then incY := -incY;
    inc(x, incX);
    inc(y, incY);
    layer^.setPosition(x, y);
  end;
end;

procedure animate(display: PDisplayAdapter; stack: PBitmapStack);
var
  dst: PBitmap;
  mS1, mS2, mS3: TMovingShape;
  sx, sy: word;
  c, ticks: longint; { for benchmarking }
  bm: PBitmap8;
begin
  dst := display^.getCanvas^.getBitmap;
  sx := (dst^.getWidth div 2) - (C_GRADIENT_W div 2);
  sy := (dst^.getHeight div 2) - (C_GRADIENT_H div 2);
  initMovingShape(mS1, stack^.getLayer(1));
  initMovingShape(mS2, stack^.getLayer(2));
  initMovingShape(mS3, stack^.getLayer(3));
  c := 0;
  bm := new(PBitmap8, initWithSize(C_GRADIENT_W, C_GRADIENT_H));
  while not keypressed do
  begin
    moveShape(mS1);
    moveShape(mS2);
    moveShape(mS3);

    dst^.merge(stack, sx, sy);

{
    (* slow but no flicker *)
    bm^.merge(stack, 0, 0);
    dst^.merge(bm, sx, sy);
}
    inc(c);
  end;
  bm^.release;
end;

var
  display: PDisplayAdapter;
  bm: PBitmap;
  gradient, shape: PBitmapLayer;
  stack: PBitmapStack;
  memAtStart: longint;

begin
  memAtStart := MemAvail;

  { set up video adapter }
  display := new(PDisplayAdapter, init);
  if not display^.detectAdapter then exit;
  display^.setVideoMode(0);

  { load all resources }
  bm := loadBitmap(C_FILE);
  stack := new(PBitmapStack, initWithSize(100, 80));

  shape := createLayer(bm, 0, 0, 26, 22, 255); { red circle }
  stack^.setLayer(1, shape);
  shape^.release;

  shape := createLayer(bm, 27, 0, 26, 22, 255); { triangle }
  stack^.setLayer(2, shape);
  shape^.release;

  shape := createLayer(bm, 54, 0, 26, 22, 255); { diamond }
  stack^.setLayer(3, shape);
  shape^.release;

  gradient := createLayer(bm, 0, 25, C_GRADIENT_W, C_GRADIENT_H, 0); { gradient }
  stack^.setLayer(0, gradient);
  gradient^.release;
  bm^.release;

  { set palette and animate on screen until key pressed }
  display^.setPalette(bm^.getPalette);
  animate(display, stack);

  { restore text mode, release all remaining objects }
  display^.setTextMode;
  stack^.release;
  display^.release;

  if memAtStart<>memAvail then
  begin
    writeln('Warning, memory leak detected.');
    beep;
  end;
end.