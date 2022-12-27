uses
  ascii, xcrt, types, utils,
  uobject, uclasses, uexc, udisplay, umouse, ukeybrd, ucanvas,
  gui, gtypes, gmsgs, gform, gcontrol, gchkbox, gfield;

const
  C_GUI_FILE = 'RES\TFEDIT.4';
  C_GRID_COLUMNS = 5;
  C_GRID_ROWS = 6;
  C_GRID_CELL_SIZE = 16;
  C_GRID_LINES_COLOR = EDarkGray;
  C_GRID_CELL_COLOR = EWhite;

var
  runFlag: boolean;

type
  PMyForm = ^TMyForm;
  TMyForm = object (TForm)
    _grid: PControl;
    _value: longint;
    procedure onStart; virtual;
    procedure onEvent(opcode: word; sender: PControl); virtual;
    function createControl: PControl; virtual;
    procedure drawGlyph;
    procedure drawGrid;
    procedure clickGrid;
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
        runFlag := false
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
begin
  beep;
end;

var
  ui: PUserInterface;
  form: PForm;
  key: char;

begin
  createDefaultDisplayAdapter;         { open default graphics mode }
  Mouse^.reset;                        { prepare the mouse after changing video mode }
  Mouse^.show;                         { show the mouse cursor }
  Mouse^.selectCursor(ECursorWait);    { use wait cursor until load is complete }
  form := new(PMyForm, init);          { create form instance }
  ui := new(PUserInterface, init);     { create user interface }
  ui^.addForm(form);                   { add the form to our user interface }
  Mouse^.setDelegate(ui^.getBus);      { send mouse messages to the user interface }
  Keyboard^.setDelegate(ui^.getBus);   { send keyboard messages to the user interface }
  ui^.render;                          { render the user interface }
  Mouse^.selectCursor(ECursorDefault); { use default cursor now that everything is loaded }

  runFlag := true;
  while runFlag do                     { stay in this loop until the flag changes }
  begin
    Mouse^.update;                     { update mouse status }
    Keyboard^.update;                  { update keyboard status }
  end;

  Mouse^.hide;                         { hide the mouse cursor }
  ui^.release;                         { destroy objects }
  form^.release;
  DisplayAdapter^.setTextMode;         { return to text mode }
end.