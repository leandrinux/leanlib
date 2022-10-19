uses
  xcrt, ubitmap, udisplay, ucanvas, ubitmap8;

const
  C_TRANSPARENT = $FF;

var
  display: PDisplayAdapter;

procedure draw(bm: PBitmap);
var
  c: PCanvas;
  w, h: word;
begin
  c := new(PCanvas, initWithBitmap(bm));
  bm^.clear(C_TRANSPARENT);
  with c^ do
  begin
    w := bm^.getWidth;
    h := bm^.getHeight;
    getStrokeBrush^.color := 1+random(15);
    rect(0, 0, w, h);
    line(0, 0, w-1, h-1);
    line(0, h-1, w-1, 0);
    release;
  end;
end;

procedure addTransparentBitmaps(dst: PBitmap);
var
  bm: PBitmap8;
begin
  randomize;
  while not keypressed do
  begin
    bm := new(PBitmap8, initWithSize(10+random(31), 10+random(31)));
    draw(bm);
    dst^.merget(bm, random(dst^.getWidth), random(dst^.getHeight), C_TRANSPARENT);
    bm^.release;
  end;
end;

procedure addOpaqueBitmaps(dst: PBitmap);
var
  bm: PBitmap8;
begin
  randomize;
  while not keypressed do
  begin
    bm := new(PBitmap8, initWithSize(10+random(31), 10+random(31)));
    draw(bm);
    dst^.merge(bm, random(dst^.getWidth), random(dst^.getHeight));
    bm^.release;
  end;
end;

begin
  display := new(PDisplayAdapter, init);
  if not display^.detectAdapter then exit;
  display^.setVideoMode(0);
  addOpaqueBitmaps(display^.getCanvas^.getBitmap);
  readkey;
  addTransparentBitmaps(display^.getCanvas^.getBitmap);
  readkey;
  display^.release;
end.