uses
  ascii, xcrt, types, utils,
  uobject, uclasses, uexc, udisplay, umouse, ukeybrd, ucanvas,
  gui, gtypes, gmsgs, gform, gcontrol, gchkbox, gfield;

const
  C_GUI_FILE = 'RES\TFEDIT.4';
  C_GRID_COLUMNS = 5;
  C_GRID_ROWS = 6;
  C_GRID_CELL_SIZE = 12;

var
  runFlag: boolean;

type
  PMyForm = ^TMyForm;
  TMyForm = object (TForm)
    _grid: PControl;
    procedure onStart; virtual;
    procedure onEvent(opcode: word; sender: PControl); virtual;
    function createControl: PControl; virtual;
    procedure drawGrid;
  end;

function TMyForm.createControl: PControl;
begin
  createControl := createControlFromFile(C_GUI_FILE);
end;

procedure TMyForm.onStart;
begin
  _grid := getRootControl^.findControl('grid');
  _grid^.getFrame^.size.width := C_GRID_CELL_SIZE * C_GRID_COLUMNS + C_GRID_COLUMNS;
  _grid^.getFrame^.size.height := C_GRID_CELL_SIZE * C_GRID_ROWS + C_GRID_ROWS;
end;

procedure TMyForm.onEvent(opcode: word; sender: PControl);
begin
  case opcode of
    C_MSG_CONTROL_CLICKED:
      if (sender^.getId = 'quitBtn') then runFlag := false;

    C_MSG_CONTROL_DRAW:
      if (sender^.getId = 'grid') then drawGrid;

  end;
end;

procedure TMyForm.drawGrid;
var
  p: TPoint;
begin
  _grid^.getAbsolutePosition(p);
  _grid^.getCanvas^.grid(p.x, p.y, 5, 6, C_GRID_CELL_SIZE, C_GRID_CELL_SIZE);
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