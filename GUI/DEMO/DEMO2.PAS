uses
  ascii, xcrt, types, utils,
  uobject, uclasses, uexc, udisplay, umouse,
  gui, gtypes, gmsgs, gapp, gform, gcontrol;

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
  case opcode of
    C_MSG_CONTROL_CLICKED:
      if PControl(sender)^.getId = 'buttonC' then
        sendMessage(C_MSG_CLOSE_SIGNAL, getDelegate)
  end;
end;

var
  app: PGUIApp;
  form: PMyForm;

begin
  app := new(PGUIApp, init);
  form := new(PMyForm, init);
  app^.run(form);
  form^.release;
  app^.release;
end.