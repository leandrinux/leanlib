uses
  ascii, xcrt, types, utils,
  uobject, uclasses, uexc, udisplay, umouse, ukeybrd,
  gui, gtypes, gmsgs, gapp, gform, gcontrol, gchkbox, gfield;

const
  C_GUI_FILE = 'RES\DEMO.3';

type
  PMyForm = ^TMyForm;
  TMyForm = object (TForm)
    public
      constructor init;
      procedure onEvent(opcode: word; sender: PControl); virtual;
    private
      field1: PTextField;
  end;

constructor TMyForm.init;
begin
  inherited init;
  loadFromFile(C_GUI_FILE);
  field1 := PTextField(getPanel^.findControl('field1'));
end;

procedure TMyForm.onEvent(opcode: word; sender: PControl);
begin
  inherited onEvent(opcode, sender);
  if (opcode = C_MSG_CONTROL_CLICKED) then
  begin
    if (sender^.getId = 'beepBtn') then
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