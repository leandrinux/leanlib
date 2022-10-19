uses
  xcrt, types, udisplay, ucanvas, uturtle, ubitmap, ubitmap1;

var
  display: PDisplayAdapter;
  turtle: PTurtle;
  _canvas: PCanvas;
  _brush: PBrush;

begin
  display := new(PDisplayAdapter, init);
  if not display^.detectAdapter then exit;
  display^.setVideoMode(0);
  _canvas := display^.getCanvas;
  _brush := _canvas^.getFillBrush;

  { draw the shape that is going to be painted }
  turtle := new(PTurtle, initWithBitmap(_canvas^.getBitmap));
  turtle^.setColor(_canvas^.getPresetColor(EBlue));
  with turtle^ do
  begin
    move(10, 10); line(30, 20); line(80, 13); line(120, 78);
    line(190, 34); line(310, 95); line(244, 167); line(159, 190);
    line(192, 145); line(32, 58); line(10, 10);

    move(180, 80); rline(40, 0); rline(14, 40);  rline(-7, 15); line(180, 80);
  end;
  turtle^.release;
  readkey;

  { paint blue area }
  _canvas^.setPatternAuxFillColor(true, _canvas^.getPresetColor(EGreen));
  _brush^.color := _canvas^.getPresetColor(ELightgreen);
  _brush^.patternScale := 5;
  _canvas^.setPattern(EDots, _brush);
  _canvas^.ffill(120, 79);
  _canvas^.setPatternAuxFillColor(false, 0);

  _brush^.patternScale := 0;
  _canvas^.setPatternAuxFillColor(true, _canvas^.getPresetColor(ELightBlue));
  _canvas^.setPattern(EZig, _brush);
  _brush^.color := _canvas^.getPresetColor(EBlue);
  _canvas^.ffill(120, 77);
  readkey;

  display^.setTextMode;
  display^.release;
end.