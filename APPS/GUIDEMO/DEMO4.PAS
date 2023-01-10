uses
  ascii,
  gapp, gmsgs, gform, gcontrol, gbutton, galert;


const
  C_FORM_JSON = 'RES\DEMO.4';

type
  PMainForm = ^TMainForm;
  TMainForm = object (TForm)
    public
      constructor init;
    private
      _button1: PButton;
      _button2: PButton;
  end;

constructor TMainForm.init;
begin
  inherited init;
  loadFromFile(C_FORM_JSON);
  with getPanel^ do
  begin
    _button1 := PButton(findControl('button1'));
    _button2 := PButton(findControl('button2'));
  end;
  _button1^.setCaption(C_CHR_TICK + ' OK');
  _button2^.setCaption(C_CHR_CLOSE + ' Cancel');
end;

var
  app: PGUIApp;
  form: PMainForm; 
{  alert: PAlertForm; }

begin
  app := new(PGUIApp, init);
  form := new(PMainForm, init); 
  { alert := new(PAlertForm, initWithTitle('Title', 'Hello world!', 0)); }
  app^.run(form);
  { alert^.release; }
  form^.release;
  app^.release;
end.