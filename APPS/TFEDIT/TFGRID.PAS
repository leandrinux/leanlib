unit TFGrid;

interface

  uses
    gcontrol;

  const
    C_GRID_COLUMNS = 5;
    C_GRID_ROWS = 6;
    C_GRID_CELL_SIZE = 16;
    C_GRID_BACKGROUND_COLOR = ord(EBlack);
    C_GRID_LINES_COLOR = ord(EDarkGray);
    C_GRID_CELL_COLOR = ord(EWhite);

  type
    PGrid = ^TGrid;
    TGrid = object(TControl)
    public
      function getValue: longint;
      procedure setValue(value: longint);
      procedure defaultDraw;
    private
      _value: longint;     
      procedure drawGrid; 
      procedure drawGlyph;
      procedure drawCell(gridPosition, cellPosition: TPoint);
    end;

implementation

  { Public }

  function TGrid.getValue: longint;
  begin
    getValue := _value;
  end;

  procedure TGrid.setValue(value: longint);
  begin
    _value := value;
  end;

  procedure TGrid.defaultDraw;
  begin
  end;

  { Private }

  procedure TGrid.drawGrid;
  var
    p: TPoint;
  begin
    getAbsolutePosition(p);
    setBackgroundStyle(EBackgroundStyleTransparent);
    with getCanvas^, getFrame^ do
    begin
        getBitmap^.setPixelBlock(p.x, p.y, p.x + size.width, p.y + size.height, C_GRID_BACKGROUND_COLOR);
        getStrokeBrush^.color := C_GRID_LINES_COLOR;
        setPattern(EDots, getStrokeBrush);
        grid(p.x, p.y, 5, 6, C_GRID_CELL_SIZE, C_GRID_CELL_SIZE);
    end;
  end;

  procedure TGrid.drawGlyph;
  var
    i: byte;
    v: longint;
    absolutePosition: TPoint;
    x, y: word;
  begin
    getAbsolutePosition(absolutePosition);
    v := _value shr 2;
    for i:= 29 downto 0 do
    begin
        if (v and 1) > 0 then
        begin
        x := 1 + absolutePosition.x + (i mod C_GRID_COLUMNS) * (C_GRID_CELL_SIZE + 1);
        y := 1 + absolutePosition.y + (i div C_GRID_COLUMNS) * (C_GRID_CELL_SIZE + 1);
        with getCanvas^.getBitmap^ do
            setPixelBlock(x, y, x + C_GRID_CELL_SIZE - 1, y + C_GRID_CELL_SIZE - 1, C_GRID_CELL_COLOR);
        end;
        v := v shr 1;
    end;
  end;

  procedure TGrid.drawCell(gridPosition, cellPosition: TPoint);
  var
    x, y: word;
    color: TColor;
  begin
    Mouse^.hide;
    x := 1 + gridPosition.x + cellPosition.x * (C_GRID_CELL_SIZE + 1);
    y := 1 + gridPosition.y + cellPosition.y * (C_GRID_CELL_SIZE + 1);
    if _value and ($80000000 shr (cellPosition.x + cellPosition.y * C_GRID_COLUMNS)) = 0 then
      color := C_GRID_BACKGROUND_COLOR
    else
      color := C_GRID_CELL_COLOR;
    with _grid^.getCanvas^.getBitmap^ do
      setPixelBlock(x, y, x + C_GRID_CELL_SIZE - 1, y + C_GRID_CELL_SIZE - 1, color);
    Mouse^.show;
  end;

end.