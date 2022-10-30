{
  GPanel Unit
  2022 LRT
}
unit
  GPanel;

interface

  uses
    consts, utils, uclasses, types, locale, ustring, ulist,
    uobject, uexc,
    gclasses, gtypes, gcontrol, gattribs, gcolors, gmsgs;

  const
    C_DEFAULT_PANEL_BORDER_STYLE = EBorderStyleNone;

  type
    PPanel = ^TPanel;
    TPanel = object (TControl)
    public
      { constructors and destructors}
      constructor initWithId(id: TControlId);
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure receiveMessage(msg: PObjectMessage); virtual;
      { methods }
      function getControls: PList;
      procedure setBorderStyle(borderStyle: EBorderStyle);
      function getBorderStyle: EBorderStyle;
    private
      _controls: PList;
      _borderStyle: EBorderStyle;
      procedure sendMouseActivity(mouseActivity: PMouseActivity);
    end;

implementation

  { TPanel public }

  constructor TPanel.initWithId(id: TControlId);
  begin
    inherited initWithId(id);
    _controls := new(PList, initWithClassFamily(C_CLASS_ID_CONTROL, C_CLASS_ID_CONTROL_FAMILY));
    _borderStyle := C_DEFAULT_PANEL_BORDER_STYLE;
  end;

  destructor TPanel.done;
  begin
    _controls^.release;
    inherited done;
  end;

  function TPanel.getClassName: string;
  begin
    getClassName := 'TPanel';
  end;

  function TPanel.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Panel;
  end;

  procedure TPanel.receiveMessage(msg: PObjectMessage);
  begin
    if msg^.opcode = C_MSG_MOUSE_ACTIVITY then
      sendMouseActivity(PMouseActivity(msg^.payload))
    else
      inherited receiveMessage(msg);
  end;

  function TPanel.getControls: PList;
  begin
    getControls := _controls;
  end;

  procedure TPanel.setBorderStyle(borderStyle: EBorderStyle);
  begin
    _borderStyle := borderStyle;
  end;

  function TPanel.getBorderStyle: EBorderStyle;
  begin
    getBorderStyle := _borderStyle;
  end;

  { TPanel private }

  procedure TPanel.sendMouseActivity(mouseActivity: PMouseActivity);
  var
    control: PControl;
    frame: PFrame;
    msg: TObjectMessage;
  begin
    _controls^.moveToStart;
    control := PControl(_controls^.getObjectAtCursor);
    while (control <> nil) and not isPointInFrame(@(mouseActivity^.position), control^.getFrame) do
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
