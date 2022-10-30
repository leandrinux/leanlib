{
  GUI Unit
  2022 LRT
}
unit
  GUI;

interface

  uses
    consts, utils, uclasses, types, locale, palette,
    uobject, uexc, udisplay, ucanvas, ubitmap, ulist, udict,
    gclasses, gtypes, grender, gmeteor, gfactory, gcontrol, gmsgs;

  type
    PUserInterface = ^TUserInterface;
    TUserInterface = object (TObject)
    public
      { constructors and destructors}
      constructor init;
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure receiveMessage(msg: PObjectMessage); virtual;
      { methods }
      function createFromData(data: PDictionary): PControl;
      function getControls: PList;
      procedure addFromData(data: PDictionary);
      procedure render;
    private
      _renderer: PRenderer;
      _controls: PList;
      procedure sendMouseActivity(mouseActivity: PMouseActivity);
    end;

implementation

  { TUserInterface public }
  constructor TUserInterface.init;
  begin
    inherited init;
    _renderer := new(PMeteor, initWithCanvas(DisplayAdapter^.getCanvas));
    _controls := new(PList, initWithClassFamily(C_CLASS_ID_CONTROL, C_CLASS_ID_CONTROL_FAMILY));
  end;

  destructor TUserInterface.done;
  begin
    _renderer^.release;
    _controls^.release;
    inherited done;
  end;

  function TUserInterface.getClassName: string;
  begin
    getClassName := 'TUserInterface';
  end;

  function TUserInterface.getClassId: word;
  begin
    getClassId := C_CLASS_ID_GUI;
  end;

  procedure TUserInterface.receiveMessage(msg: PObjectMessage);
  begin
    if msg^.opcode = C_MSG_MOUSE_ACTIVITY then
      sendMouseActivity(PMouseActivity(msg^.payload))
    else if msg^.opcode = C_MSG_CONTROL_REQUEST_REDRAW then
    begin
      _renderer^.render(PControl(msg^.sender));
    end;
  end;

  function TUserInterface.createFromData(data: PDictionary): PControl;
  var
    cf: PControlFactory;
  begin
    cf := new(PControlFactory, init);
    createFromData := cf^.create(data);
    cf^.release;    
  end;

  function TUserInterface.getControls: PList;
  begin
    getControls := _controls;
  end;

  procedure TUserInterface.addFromData(data: PDictionary);
  var
    control: PControl;
  begin
    control := createFromData(data);
    control^.setDelegate(@self);
    _controls^.addObject(control);
    control^.release;
  end;

  procedure TUserInterface.render;
  var
    control: PControl;
  begin
    _controls^.moveToStart;
    control := PControl(_controls^.getObjectAtCursor);
    while control <> nil do
    begin
      _renderer^.render(control);
      _controls^.moveForward;
      control := PControl(_controls^.getObjectAtCursor);
    end;
  end;

  { TUserInterface private }

  procedure TUserInterface.sendMouseActivity(mouseActivity: PMouseActivity);
  var
    control: PControl;
    frame: PFrame;
    msg: TObjectMessage;
  begin
    _controls^.moveToStart;
    control := PControl(_controls^.getObjectAtCursor);
    while (control <> nil) and not isPointInFrame(@mouseActivity^.position, control^.getFrame) do
    begin
      _controls^.moveForward;
      control := PControl(_controls^.getObjectAtCursor);
    end;
    if control <> nil then
    begin
      with control^.getFrame^.point do
      begin
        dec(mouseActivity^.position.x, x);
        dec(mouseActivity^.position.y, y);
        msg.opcode := C_MSG_MOUSE_ACTIVITY;
        msg.payload := mouseActivity;
        control^.receiveMessage(@msg);
      end;
    end;
  end;

  { Other }

end.
