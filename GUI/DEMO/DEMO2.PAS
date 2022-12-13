uses
  ascii, xcrt, types, utils,
  uobject, uclasses, uexc, udisplay, umouse, ucomlog,
  gui, gtypes, gmsgs, gform, gcontrol;

const
  C_GUI_FILE = 'RES\DEMO.2';

type
  PMyForm = ^TMyForm;
  TMyForm = object (TForm)
    procedure onEvent(opcode: word; sender: PControl); virtual;
    function createControl: PControl; virtual;
  end;

function TMyForm.createControl: PControl;
begin
  createControl := createControlFromFile(C_GUI_FILE);
end;

procedure TMyForm.onEvent(opcode: word; sender: PControl);
begin
  log('onEvent from ' + sender^.getId);
end;

var
  mouse: PMouse;
  ui: PUserInterface;
  form: PForm;
  key: char;

begin
  createDefaultDisplayAdapter;         { open default graphics mode }
  mouse := new(PMouse, init);          { create mouse instance }
  form := new(PMyForm, init);          { create form instance }
  ui := new(PUserInterface, init);     { create user interface }
  ui^.addForm(form);                   { add the form to our user interface }
  mouse^.setDelegate(ui^.getBus);      { send mouse messages to the user interface }
  mouse^.show;                         { show the mouse cursor }
  ui^.render;                          { render the user interface }

  key := #0;
  while key <> C_ESC do                { stay in this loop until the ESC key is pressed }
  begin
    if keypressed then key := readkey;
    mouse^.update;                     { update mouse status }
  end;

  mouse^.hide;                         { hide the mouse cursor }
  ui^.release;                         { destroy objects }
  form^.release;
  mouse^.release;
  DisplayAdapter^.setTextMode;         { return to text mode }
end.