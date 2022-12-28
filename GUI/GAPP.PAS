{
  GApp Unit
  2022 LRT
}
unit
  GApp;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, udisplay, umouse, ukeybrd,
    gclasses, gmsgs, gtypes, gform, GUI;

  type
    PGUIApp = ^TGUIApp;
    TGUIApp = object (TObject)
    public
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure receiveMessage(msg: PObjectMessage); virtual;
      { methods }
      procedure run(form: PForm);
      procedure stop;
    private
      _runFlag: boolean;
    end;

implementation

  { TGUIApp public }

  function TGUIApp.getClassName: string;
  begin
    getClassName := 'TGUIApp';
  end;

  function TGUIApp.getClassId: word;
  begin
    getClassId := C_CLASS_ID_GUIApp;
  end;

  procedure TGUIApp.receiveMessage(msg: PObjectMessage);
  begin
    if msg^.opcode = C_MSG_CLOSE_SIGNAL then stop;
  end;

  procedure TGUIApp.run(form: PForm);
  var
    ui: PUserInterface;
  begin
    DisplayAdapter^.setVideoMode(0);     { open first available graphics mode }
    Mouse^.reset;                        { prepare the mouse after changing video mode }
    Mouse^.show;                         { show the mouse cursor }
    ui := new(PUserInterface, init);     { create user interface }
    form^.setDelegate(@self);            { sets itself as parent to listen for close message }
    ui^.addForm(form);                   { add the form to our user interface }
    Mouse^.setDelegate(ui^.getBus);      { send mouse messages to the user interface }
    Keyboard^.setDelegate(ui^.getBus);   { send keyboard messages to the user interface }
    ui^.render;                          { render the user interface }
    Mouse^.selectCursor(ECursorDefault); { use default cursor now that everything is loaded }

    _runFlag := true;
    while _runFlag do                    { stay in this loop until the flag changes }
    begin
      Mouse^.update;                     { update mouse status }
      Keyboard^.update;                  { update keyboard status }
    end;

    Mouse^.hide;                         { hide the mouse cursor }
    ui^.release;                         { destroy objects }
    DisplayAdapter^.setTextMode;         { return to text mode }
  end;

  procedure TGUIApp.stop;
  begin
    _runFlag := false;
  end;

  { TGUIApp private }

  { Other }

end.
