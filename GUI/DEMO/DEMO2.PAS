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
  ui: PUserInterface;
  form: PForm;
  key: char;

begin
  createDefaultDisplayAdapter;         { open default graphics mode }
  Mouse^.reset;                        { prepare the mouse after changing video mode }
  form := new(PMyForm, init);          { create form instance }
  ui := new(PUserInterface, init);     { create user interface }
  ui^.addForm(form);                   { add the form to our user interface }
  Mouse^.setDelegate(ui^.getBus);      { send mouse messages to the user interface }
  Mouse^.show;                         { show the mouse cursor }
  ui^.render;                          { render the user interface }

  key := #0;
  while key <> C_ESC do                { stay in this loop until the ESC key is pressed }
  begin
    if keypressed then key := readkey;
    Mouse^.update;                     { update mouse status }
  end;

  Mouse^.hide;                         { hide the mouse cursor }
  ui^.release;                         { destroy objects }
  form^.release;
  DisplayAdapter^.setTextMode;         { return to text mode }
end.