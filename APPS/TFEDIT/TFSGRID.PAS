unit
  TFSGrid;

interface

  uses
    types, utils,
    uobject, umsgs, ucanvas, umouse, utfont,
    gtypes, gcontrol,
    tfebase;

  type
    PSymbolGrid = ^TSymbolGrid;
    TSymbolGrid = object(TControl)
    public
      constructor init;
      destructor done; virtual;
      procedure defaultDraw; virtual;
      procedure receiveMessage(msg: PObjectMessage); virtual;
      procedure setFont(font: PTinyFont);
      function getFont: PTinyFont;
      function getSelectedSymbol: longint;
      function getSelectedChar: char;
    private
      _font: PTinyFont;
      _selectedIndex: byte;
      _selectedPoint: TPoint;
      _selectedSymbol: longint;
      procedure onClick(mousePosition: PPoint);
    end;

implementation

  const
    C_GRID_BACKGROUND_COLOR = ord(ELightGray);
    C_GRID_BORDER_COLOR = ord(EDarkGray);
    C_GRID_selected_COLOR = ord(ELightBlue);
    C_GRID_CELL_SIDE_COUNT = 16;
    C_GRID_CELL_SIZE = 8;
    C_GRID_SIZE = 1 + C_GRID_CELL_SIDE_COUNT * C_GRID_CELL_SIZE + C_GRID_CELL_SIDE_COUNT;

  { Public }

  constructor TSymbolGrid.init;
  begin
    inherited init;
    _font := nil;
    _selectedIndex := 0;
    _selectedSymbol := 0;
    with _selectedPoint do
    begin
      x := 0;
      y := 0;
    end;
    setBackgroundStyle(EBackgroundStyleTransparent);
    with getFrame^.size do
    begin
      width := C_GRID_SIZE;
      height := C_GRID_SIZE;
    end;
  end;

  destructor TSymbolGrid.done;
  begin
    inherited done;
  end;

  procedure TSymbolGrid.defaultDraw;
  var
    p, position: TPoint;
    i: byte;
  begin
    getAbsolutePosition(position);
    with getCanvas^ do
    begin
      getStrokeBrush^.color := C_GRID_BORDER_COLOR;
      setPattern(EDots, getStrokeBrush);
      with position do 
      begin
        rect(x, y, C_GRID_SIZE, C_GRID_SIZE);
        grid(x, y, C_GRID_CELL_SIDE_COUNT, C_GRID_CELL_SIDE_COUNT, C_GRID_CELL_SIZE, C_GRID_CELL_SIZE);
      end;
      setPattern(ESolid, getStrokeBrush);
      if _font <> nil then
      begin
        for i := 0 to 255 do
        begin
          p.x := position.x + 2 + (i mod C_GRID_CELL_SIDE_COUNT) * (C_GRID_CELL_SIZE + 1);
          p.y := position.y + 2 + (i div C_GRID_CELL_SIDE_COUNT) * (C_GRID_CELL_SIZE + 1);
          _font^.drawChar(chr(i), 1, p.x, p.y, getCanvas);
        end;
      end;
      getStrokeBrush^.color := C_GRID_selected_COLOR;
      with _selectedPoint do
        rect(
          position.x + x * (C_GRID_CELL_SIZE + 1), 
          position.y + y * (C_GRID_CELL_SIZE + 1), 
          C_GRID_CELL_SIZE + 2, C_GRID_CELL_SIZE + 2
        );
    end;
  end;

  procedure TSymbolGrid.receiveMessage(msg: PObjectMessage);
  begin
    if msg^.opcode = C_MSG_MOUSE_LEFT_DOWN then 
      onClick(msg^.payload);  
  end;
  
  procedure TSymbolGrid.setFont(font: PTinyFont);
  begin
    _font := font;
  end;

  function TSymbolGrid.getFont: PTinyFont;
  begin
    getFont := _font;
  end;

  function TSymbolGrid.getSelectedSymbol: longint;
  begin
    getSelectedSymbol := _selectedSymbol;
  end;

  function TSymbolGrid.getSelectedChar: char;
  begin
    getSelectedChar := chr(_selectedIndex);
  end;

  { Private }

  procedure TSymbolGrid.onClick(mousePosition: PPoint);
  var
    frame: TFrame;  
    symbol: plong;
  begin
    frame := getFrame^;
    getAbsolutePosition(frame.point);
    if isPointInFrame(mousePosition, @frame) then
    begin
      Mouse^.hide;
      with getCanvas^, _selectedPoint do
      begin
        getStrokeBrush^.color := C_GRID_BACKGROUND_COLOR;
        setPattern(ESolid, getStrokeBrush);
        rect(
          frame.point.x + x * (C_GRID_CELL_SIZE + 1), 
          frame.point.y + y * (C_GRID_CELL_SIZE + 1), 
          C_GRID_CELL_SIZE + 2, C_GRID_CELL_SIZE + 2
        );
        getStrokeBrush^.color := C_GRID_BORDER_COLOR;
        setPattern(EDots, getStrokeBrush);
        rect(
          frame.point.x + x * (C_GRID_CELL_SIZE + 1), 
          frame.point.y + y * (C_GRID_CELL_SIZE + 1), 
          C_GRID_CELL_SIZE + 2, C_GRID_CELL_SIZE + 2
        );
      end;

      with _selectedPoint do
      begin
        x := (mousePosition^.x - frame.point.x) div (C_GRID_CELL_SIZE + 1);
        y := (mousePosition^.y - frame.point.y) div (C_GRID_CELL_SIZE + 1);
        _selectedIndex := y * C_GRID_CELL_SIDE_COUNT + x;
        if _font <> nil then
        begin
          _selectedSymbol := _font^.getSymbol(chr(_selectedIndex));
        end else
          _selectedSymbol := 0;
      end;

      with getCanvas^, _selectedPoint do
      begin
        getStrokeBrush^.color := C_GRID_selected_COLOR;
        setPattern(ESolid, getStrokeBrush);
        rect(
          frame.point.x +  x * (C_GRID_CELL_SIZE + 1), 
          frame.point.y +  y * (C_GRID_CELL_SIZE + 1), 
          C_GRID_CELL_SIZE + 2, C_GRID_CELL_SIZE + 2
        );
      end;
      Mouse^.show;
      sendMessage(C_MSG_CHANGED_SELECTION, getDelegate);
    end;
  end;

end.