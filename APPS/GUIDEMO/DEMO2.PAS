uses
  ascii, xcrt, types, utils,
  uobject, uclasses, uexc, udisplay, umouse,
  gui, gtypes, gmsgs, gapp, gform, gcontrol;

const
  C_GUI_FILE = 'RES\DEMO.2';

type
  PMyForm = ^TMyForm;
  TMyForm = object (TForm)
    constructor init;
  end;

constructor TMyForm.init;
begin
  inherited init;
  loadFromFile(C_GUI_FILE);
  getTitleLabel^.getFrame^.size.width := getPanel^.getFrame^.size.width;  
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