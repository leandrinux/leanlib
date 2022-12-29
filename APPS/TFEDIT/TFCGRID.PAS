unit
  TFCGrid;

interface

  uses
    types, utils,
    uobject, umsgs, ucanvas, umouse, utfont,
    gtypes, gcontrol;

  type
    PSymbolGrid = ^TSymbolGrid;
    TSymbolGrid = object(TControl)
    public
      constructor init;
      destructor done; virtual;
      procedure defaultDraw; virtual;
      procedure receiveMessage(msg: PObjectMessage); virtual;
      procedure setFontData(fontData: PTinyFontData);
      function getFont: PTinyFont;
    private
      _font: PTinyFont;
      _fontData: PTinyFontData;
      _selectedIndex: byte;
    end;

implementation

  const
    C_GRID_CELL_SIDE_SIZE = 16;
    C_GRID_CELL_SIZE = 8;
    C_GRID_SIZE = 1 + C_GRID_CELL_SIDE_SIZE * C_GRID_CELL_SIZE + C_GRID_CELL_SIDE_SIZE;

  constructor TSymbolGrid.init;
  begin
    inherited init;
    _font := nil;
    _fontData := nil;
    _selectedIndex := 0;
    setBackgroundStyle(EBackgroundStyleTransparent);
    with getFrame^.size do
    begin
      width := C_GRID_SIZE;
      height := C_GRID_SIZE;
    end;
  end;

  destructor TSymbolGrid.done;
  begin
    if _font <> nil then _font^.release;
    inherited done;
  end;

  procedure TSymbolGrid.defaultDraw;
  var
    p, position: TPoint;
    i: byte;
    symbol: plong;

  begin
    getAbsolutePosition(position);
    with getCanvas^ do
    begin
      getStrokeBrush^.color := ord(EDarkGray);
      setPattern(EDots, getStrokeBrush);
      with position do 
      begin
        rect(x, y, C_GRID_SIZE, C_GRID_SIZE);
        grid(x, y, C_GRID_CELL_SIDE_SIZE, C_GRID_CELL_SIDE_SIZE, C_GRID_CELL_SIZE, C_GRID_CELL_SIZE);
      end;
      setPattern(ESolid, getStrokeBrush);
      if _fontData <> nil then
      begin
        symbol := _fontData^.symbols;
        for i := 0 to 255 do
        begin
          p.x := position.x + 2 + (i mod C_GRID_CELL_SIDE_SIZE) * (C_GRID_CELL_SIZE + 1);
          p.y := position.y + 2 + (i div C_GRID_CELL_SIDE_SIZE) * (C_GRID_CELL_SIZE + 1);
          {
          with getCanvas^.getBitmap^ do
            setPixelBlock(p.x, p.y, p.x + C_GRID_CELL_SIZE - 1, p.y + C_GRID_CELL_SIZE - 1, ord(EGreen));
          }
          _font^.drawChar(chr(i), 1, p.x, p.y, getCanvas);
          inc(symbol);
        end;
      end;
    end;
  end;

  procedure TSymbolGrid.receiveMessage(msg: PObjectMessage);
  begin
  end;
  
  procedure TSymbolGrid.setFontData(fontData: PTinyFontData);
  begin
    _fontData := fontData;
    if _font <> nil then _font^.release;
    _font := new(PTinyFont, initWithData(_fontData));
  end;

  function TSymbolGrid.getFont: PTinyFont;
  begin
    getFont := _font;
  end;

end.