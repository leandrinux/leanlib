unit TFForm;
    
interface

  uses
    ascii, xcrt, types, utils,
    uobject, uclasses, uexc, udisplay, umouse, ukeybrd, ucanvas,
    gui, gtypes, gmsgs, gform, gcontrol, gchkbox, gfield;

  type
    PMyForm = ^TMyForm;
    TMyForm = object (TForm)
      public
        quitFlag: boolean;
        constructor init;
        procedure onStart; virtual;
        procedure onEvent(opcode: word; sender: PControl); virtual;
        function createControl: PControl; virtual;
      private
        _grid: PControl;
        _value: longint;
        procedure drawGlyph;
        procedure drawGrid;
        procedure clickGrid;
    end;

implementation

  const
    C_GUI_FILE = 'TFEDIT.4';
    C_GRID_COLUMNS = 5;
    C_GRID_ROWS = 6;
    C_GRID_CELL_SIZE = 16;
    C_GRID_LINES_COLOR = EDarkGray;
    C_GRID_CELL_COLOR = EWhite;

  { Public }

  constructor TMyForm.init;
  begin
    inherited init;
    quitFlag := false;
  end;

  function TMyForm.createControl: PControl;
  begin
    createControl := createControlFromFile(C_GUI_FILE);
  end;
  
  procedure TMyForm.onStart;
  begin
    _value := $FC39087C;
    _grid := getRootControl^.findControl('grid');
    _grid^.getFrame^.size.width := C_GRID_CELL_SIZE * C_GRID_COLUMNS + C_GRID_COLUMNS;
    _grid^.getFrame^.size.height := C_GRID_CELL_SIZE * C_GRID_ROWS + C_GRID_ROWS;
  end;

  procedure TMyForm.onEvent(opcode: word; sender: PControl);
  begin
    case opcode of
        C_MSG_CONTROL_CLICKED:
        if (sender^.getId = 'quitBtn') then 
            quitFlag := true
        else if (sender^.getId = 'grid') then 
            clickGrid; 

        C_MSG_CONTROL_DRAW:
        if (sender^.getId = 'grid') then
        begin
            drawGrid;
            drawGlyph;
        end;
    end;
  end;

  { Private }

  procedure TMyForm.drawGrid;
  var
    p: TPoint;
    c: PCanvas;
  begin
    _grid^.getAbsolutePosition(p);
    _grid^.setBackgroundStyle(EBackgroundStyleTransparent);
    with _grid^, getCanvas^, getFrame^ do
    begin
        getBitmap^.setPixelBlock(p.x, p.y, p.x + size.width, p.y + size.height, ord(EBlack));
        getStrokeBrush^.color := ord(C_GRID_LINES_COLOR);
        setPattern(EDots, getStrokeBrush);
        grid(p.x, p.y, 5, 6, C_GRID_CELL_SIZE, C_GRID_CELL_SIZE);
    end;
  end;

  procedure TMyForm.drawGlyph;
  var
    i: byte;
    v: longint;
    absolutePosition: TPoint;
    x, y: word;
  begin
    _grid^.getAbsolutePosition(absolutePosition);
    v := _value shr 2;
    for i:= 29 downto 0 do
    begin
        if (v and 1) > 0 then
        begin
        x := 1 + absolutePosition.x + (i mod C_GRID_COLUMNS) * (C_GRID_CELL_SIZE + 1);
        y := 1 + absolutePosition.y + (i div C_GRID_COLUMNS) * (C_GRID_CELL_SIZE + 1);
        with _grid^.getCanvas^.getBitmap^ do
            setPixelBlock(x, y, x + C_GRID_CELL_SIZE - 1, y + C_GRID_CELL_SIZE - 1, ord(C_GRID_CELL_COLOR));
        end;
        v := v shr 1;
    end;
  end;
 
  procedure TMyForm.clickGrid;
  var
    mousePosition: TPoint;
    gridPosition: TPoint;
    cellPosition: TPoint;
  begin
    _grid^.getAbsolutePosition(gridPosition);
    mousePosition := Mouse^.getPosition^;
    cellPosition.x := (mousePosition.x - gridPosition.x) div (C_GRID_CELL_SIZE + 1);
    cellPosition.y := (mousePosition.y - gridPosition.y) div (C_GRID_CELL_SIZE + 1);
    _value := _value xor ($80000000 shr (cellPosition.x + cellPosition.y * C_GRID_COLUMNS));
    Mouse^.hide;
    drawGrid;
    drawGlyph;
    Mouse^.show;
  end;
   
end.