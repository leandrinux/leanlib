uses
  xcrt, types, palette, udisplay, ucanvas, ulog, userial, upath;

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

procedure doLines(canvas: PCanvas);
var
  p: PPath;
begin
  p := canvas^.createLinePath(0, 0, 30, 10);
  canvas^.plot(p, canvas^.getStrokeBrush, 0, 0);
  canvas^.plot(p, canvas^.getStrokeBrush, 0, 10);
  canvas^.plot(p, canvas^.getStrokeBrush, 0, 20);
  canvas^.plot(p, canvas^.getStrokeBrush, 0, 30);
  p^.release;
end;

procedure doCircles(canvas: PCanvas);
var
  p: PPath;
begin
  p := canvas^.createCirclePath(0, 0, 15);
  canvas^.plot(p, canvas^.getStrokeBrush, 50, 0);
  canvas^.plot(p, canvas^.getStrokeBrush, 50, 20);
  canvas^.plot(p, canvas^.getStrokeBrush, 50, 40);
  canvas^.plot(p, canvas^.getStrokeBrush, 50, 60);
  p^.release;
end;

procedure doPlotAlong(canvas: PCanvas);
var
  pA, pB: PPath;
  brush: PBrush;
begin
  pA := canvas^.createCirclePath(0, 0, 15);
  pB := canvas^.createLinePath(90, 50, 160, 150);
  brush := canvas^.getStrokeBrush;
  brush^.color := palette.getColor(ELightRed, 8);
  canvas^.plot(pB, brush, 0, 0); 
  brush^.color := palette.getColor(ERed, 8);
  canvas^.plotAlongPath(pA, pB, brush);
  pA^.release;
  pB^.release;
end;

var
  display: PDisplayAdapter;
  c: PCanvas;
  brush: PBrush;

begin
  initLog;
  display := new(PDisplayAdapter, init);
  display^.detectAdapter;
  display^.setVideoMode(0);
  c := display^.getCanvas;
  with c^ do
  begin
    brush := getStrokeBrush;
    brush^.color := palette.getColor(EMagenta, 8);
    setPixel(0, 0, brush);
    setPixel(319, 0, brush);
    setPixel(0, 199, brush);
    setPixel(319, 199, brush);
    doLines(c);
    doCircles(c);
    doPlotAlong(c);
  end;
  readkey;
  display^.release;
end.