{
  GControl Unit
  2022 LRT
}
unit
  GControl;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, umsgbus, 
    gclasses, gtypes, gcolors, gmsgs;

  type
    PControl = ^TControl;
    TControl = object (TObject)
    public
      { constructors and destructors}
      constructor initWithId(id: TControlId);
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure receiveMessage(msg: PObjectMessage); virtual;
      { methods }
      procedure setBus(bus: PMessageBus); virtual;
      function getBus: PMessageBus;
      function getFrame: PFrame;
      function getId: TControlId;
      function getParent: PControl;
      procedure setParent(parent: PControl);
      procedure getAbsolutePosition(var point: TPoint);
      procedure setBackgroundColor(backgroundColor: TColor);
      function getBackgroundColor: TColor;     
      procedure setBackgroundStyle(backgroundStyle: EBackgroundStyle);
      function getBackgroundStyle: EBackgroundStyle;
    private
      _bus: PMessageBus;
      _frame: TFrame;
      _id: TControlID;
      _parent: PControl;
      _backgroundColor: TColor;
      _backgroundStyle: EBackgroundStyle;
    end;

implementation

  { TControl public }

  constructor TControl.initWithId(id: TControlId);
  begin
    inherited init;
    _id := id;
    _parent := nil;
    _bus := nil;
    _backgroundColor := DefaultColorScheme^.getColor(ECKPanelBackground);
    _backgroundStyle := EBackgroundStyleSolid;
  end;

  destructor TControl.done;
  begin
    inherited done;
  end;

  function TControl.getClassName: string;
  begin
    getClassName := 'TControl';
  end;

  function TControl.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Control;
  end;

  procedure TControl.receiveMessage(msg: PObjectMessage);
  begin
  end;

  procedure TControl.setBus(bus: PMessageBus);
  begin
    if _bus <> nil then _bus^.unsubscribe(@self);
    _bus := bus;
    _bus^.subscribe(@self);
  end;

  function TControl.getBus: PMessageBus;
  begin
    getBus := _bus;
  end;

  function TControl.getFrame: PFrame;
  begin
    getFrame := @_frame;
  end;

  function TControl.getId: TControlId;
  begin
    getId := _id;
  end;

  function TControl.getParent: PControl;
  begin
    getParent := _parent;
  end;

  procedure TControl.setParent(parent: PControl);
  begin
    _parent := parent;
  end;

  procedure TControl.getAbsolutePosition(var point: TPoint);
  begin
    with point do
      if _parent = nil then
      begin
        x := _frame.point.x;
        y := _frame.point.y;
      end else begin
        _parent^.getAbsolutePosition(point);
        x := x + _frame.point.x;
        y := y + _frame.point.y;
      end;
  end;

  procedure TControl.setBackgroundColor(backgroundColor: TColor);
  begin
    _backgroundColor := backgroundColor;
  end;

  function TControl.getBackgroundColor: TColor;
  begin
    getBackgroundColor := _backgroundColor;
  end;
  
  procedure TControl.setBackgroundStyle(backgroundStyle: EBackgroundStyle);
  begin
    _backgroundStyle := backgroundStyle;
  end;

  function TControl.getBackgroundStyle: EBackgroundStyle;
  begin
    getBackgroundStyle := _backgroundStyle;
  end;

  { TControl private }

  { Other }

end.
