{
  GUI Unit
  2022 LRT
}
unit
  GUI;

interface

  uses
    consts, utils, uclasses, types, locale, palette,
    uobject, uexc, udisplay, ucanvas, ubitmap, ulist, udict, umsgbus,
    gclasses, gtypes, grender, gmeteor, gcontrol, gpanel, gmsgs, gform;

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
      procedure addForm(form: PForm);
      procedure render;
      function getBus: PMessageBus;
    private
      _renderer: PRenderer;
      _forms: PList;
      _bus: PMessageBus;
      procedure notifyFormAboutEvent(msg: PObjectMessage);
    end;

implementation

  { TUserInterface public }
  constructor TUserInterface.init;
  begin
    inherited init;
    _renderer := new(PMeteor, initWithCanvas(DisplayAdapter^.getCanvas));
    _forms := new(PList, initWithClassFamily(C_CLASS_ID_FORM_FROM, C_CLASS_ID_FORM_TO));
    _bus := new(PMessageBus, init);
    _bus^.subscribe(@self);
  end;

  destructor TUserInterface.done;
  begin
    _renderer^.release;
    _forms^.release;
    _bus^.release;
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
    if msg^.opcode = C_MSG_CONTROL_REQUEST_REDRAW then
      _renderer^.render(PControl(msg^.sender))
    else if (msg^.opcode and C_MSG_CONTROL_EVENT_MASK) = C_MSG_CONTROL_EVENT_MASK then
      notifyFormAboutEvent(msg);
  end;

  procedure TUserInterface.addForm(form: PForm);
  begin
    form^.getPanel^.setBus(_bus);
    _forms^.addObject(form);
  end;

  procedure TUserInterface.render;
  var
    form: PForm;
  begin
    _forms^.moveToStart;
    form := PForm(_forms^.getObjectAtCursor);
    while form <> nil do
    begin
      _renderer^.render(form^.getPanel);
      _forms^.moveForward;
      form := PForm(_forms^.getObjectAtCursor);
    end;
  end;

  function TUserInterface.getBus: PMessageBus;
  begin
    getBus := _bus;
  end;

  { TUserInterface private }

  procedure TUserInterface.notifyFormAboutEvent(msg: PObjectMessage);
  var
    control: PControl;
    form: PForm;
  begin
    { find the root control to this control }
    control := PControl(msg^.sender);
    while control^.getParent <> nil do control := control^.getParent;
    { find the form that has that root control}
    _forms^.moveToStart;
    form := PForm(_forms^.getObjectAtCursor);
    while (form <> nil) and (PControl(form^.getPanel) <> control) do
    begin
      _forms^.moveForward;
      form := PForm(_forms^.getObjectAtCursor);
    end;
    { if form was found then notify about this event }
    if form <> nil then
      form^.onEvent(msg^.opcode, PControl(msg^.sender));
  end;

  { Other }

end.
