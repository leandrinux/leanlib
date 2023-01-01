uses
  ascii,
  gapp, gmsgs, gform, gcontrol, gbutton;

const
  C_FORM_JSON = 'RES\DEMO.4';

type
  PMainForm = ^TMainForm;
  TMainForm = object (TForm)
    _quitButton: PButton;
    _button1: PButton;
    _button2: PButton;
    function createControl: PControl; virtual;
    procedure onStart; virtual;
    procedure onEvent(opcode: word; sender: PControl); virtual;
  end;

function TMainForm.createControl: PControl;
begin
  createControl := createControlFromFile(C_FORM_JSON);
end;

procedure TMainForm.onStart;
begin
  with getRootControl^ do
  begin
    _quitButton := PButton(findControl('quit'));
    _button1 := PButton(findControl('button1'));
    _button2 := PButton(findControl('button2'));
  end;
  _button1^.setCaption(C_CHR_TICK + ' OK');
  _button2^.setCaption(C_CHR_ERROR + ' Cancel');
end;

procedure TMainForm.onEvent(opcode: word; sender: PControl);
begin
  if (opcode = C_MSG_CONTROL_CLICKED) and (sender^.getId = 'quit') then
    sendMessage(C_MSG_CLOSE_SIGNAL, getDelegate);
end;

var
  app: PGUIApp;
  form: PMainForm;

begin
  app := new(PGUIApp, init);
  form := new(PMainForm, init);
  app^.run(form);
  form^.release;
  app^.release;
end.