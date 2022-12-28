uses
  GApp, TFForm;

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