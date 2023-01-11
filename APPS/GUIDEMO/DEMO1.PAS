uses
  ascii, xcrt, types, utils,
  uobject, uclasses, uexc, udisplay, umouse,
  gui, gtypes, gmsgs, gapp, gform, gcontrol;

type
  PMyForm = ^TMyForm;
  TMyForm = object (TForm)
    constructor init;
  end;

constructor TMyForm.init;
begin
  inherited init;
  getTitleLabel^.setText('Hello World!');
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