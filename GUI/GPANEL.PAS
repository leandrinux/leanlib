{
  GPanel Unit
  2022 LRT
}
unit
  GPanel;

interface

  uses
    consts, utils, types, locale, 
    uclasses, ustring, ulist, uobject, uexc, umsgbus,
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
      procedure setBus(bus: PMessageBus); virtual;
      { methods }
      function getControls: PList;
      procedure setBorderStyle(borderStyle: EBorderStyle);
      function getBorderStyle: EBorderStyle;
    private
      _controls: PList;
      _borderStyle: EBorderStyle;
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
  end;

  procedure TPanel.setBus(bus: PMessageBus);
  var
    control: PControl;
  begin
    inherited setBus(bus);
    _controls^.moveToStart;
    control := PControl(_controls^.getObjectAtCursor);
    while control <> nil do
    begin
      control^.setBus(bus);
      _controls^.moveForward;
      control := PControl(_controls^.getObjectAtCursor);
    end;
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

  { Other }

end.
