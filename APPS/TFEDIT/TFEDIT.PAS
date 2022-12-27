uses
  udisplay, umouse, ukeybrd,
  GUI, 
  TFForm;

var
  ui: PUserInterface;
  form: PMyForm;
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
  Keyboard^.setDelegate(ui^.getBus);   { send keyboard messages to the user interface }
  ui^.render;                          { render the user interface }
  Mouse^.selectCursor(ECursorDefault); { use default cursor now that everything is loaded }

  while not form^.quitFlag do                     { stay in this loop until the flag changes }
  begin
    Mouse^.update;                     { update mouse status }
    Keyboard^.update;                  { update keyboard status }
  end;

  Mouse^.hide;                         { hide the mouse cursor }
  ui^.release;                         { destroy objects }
  form^.release;
  DisplayAdapter^.setTextMode;         { return to text mode }
end.