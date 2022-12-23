uses
  ascii, xcrt, types, utils,
  uobject, uclasses, uexc, udisplay, umouse,
  gui, gtypes, gmsgs, gform, gcontrol;

const
  C_GUI_FILE = 'RES\DEMO.3';

var
  runFlag: boolean;

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
  if (opcode = C_MSG_CONTROL_CLICKED) then
  begin
    if (sender^.getId = 'quitBtn') then
    begin 
      runFlag := false;
    end else if (sender^.getId = 'beepBtn') then
    begin
      beep;
    end; 
  end;
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
  ui^.render;                          { render the user interface }
  Mouse^.selectCursor(ECursorDefault); { use default cursor now that everything is loaded }

  runFlag := true;
  while runFlag do                     { stay in this loop until the flag changes }
    Mouse^.update;                     { update mouse status }

  Mouse^.hide;                         { hide the mouse cursor }
  ui^.release;                         { destroy objects }
  form^.release;
  DisplayAdapter^.setTextMode;         { return to text mode }
end.