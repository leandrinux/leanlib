uses
  ascii, xcrt, types, utils,
  uobject, uclasses, uexc, udisplay, umouse, ukeybrd,
  gui, gtypes, gmsgs, gapp, gform, gcontrol, gchkbox, gfield;

const
  C_GUI_FILE = 'RES\DEMO.3';

var
  runFlag: boolean;

type
  PMyForm = ^TMyForm;
  TMyForm = object (TForm)
    field1: PTextField;
    procedure onStart; virtual;
    procedure onEvent(opcode: word; sender: PControl); virtual;
    function createControl: PControl; virtual;
  end;

function TMyForm.createControl: PControl;
begin
  createControl := createControlFromFile(C_GUI_FILE);
end;

procedure TMyForm.onStart;
begin
  field1 := PTextField(getRootControl^.findControl('field1'));
end;

procedure TMyForm.onEvent(opcode: word; sender: PControl);
begin
  if (opcode = C_MSG_CONTROL_CLICKED) then
  begin
    if (sender^.getId = 'quitBtn') then
    begin
      sendMessage(C_MSG_CLOSE_SIGNAL, getDelegate);
    end else if (sender^.getId = 'beepBtn') then
    begin
      beep;
    end else if (sender^.getId = 'chkbox1') then
    begin
      field1^.setEnabled(not field1^.isEnabled);
    end;
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