{
  GControl Unit
  2022 LRT
}
unit
  GControl;

interface

  uses
  xcrt,
    consts, utils, uclasses, types, locale,
    uobject, uexc, umsgbus, ucanvas, umsgs,
    gclasses, gtypes, gcolors, gmsgs;

  type
    PControl = ^TControl;
    TControl = object (TObject)
    public
      { constructors and destructors}
      constructor init;
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure receiveMessage(msg: PObjectMessage); virtual;
      { methods }
      procedure setBus(bus: PMessageBus); virtual;
      function getBus: PMessageBus;
      function getFrame: PFrame;
      procedure setId(id: TControlId);
      function getId: TControlId;
      function getParent: PControl;
      procedure setParent(parent: PControl);
      procedure getAbsolutePosition(var point: TPoint);
      procedure setBackgroundColor(backgroundColor: TColor);
      function getBackgroundColor: TColor;     
      procedure setBackgroundStyle(backgroundStyle: EBackgroundStyle);
      function getBackgroundStyle: EBackgroundStyle;
      procedure setEnabled(enabled: boolean); virtual;
      function isEnabled: boolean;
      function findControl(id: TControlId): PControl; virtual;
      procedure setAlignment(alignment: EAlignment);
      function getAlignment: EAlignment;
      procedure setCanvas(canvas: PCanvas);
      function getCanvas: PCanvas;
      procedure defaultDraw; virtual;
      procedure requestRedraw;
      procedure setHidden(hidden: boolean);
      function isHidden: boolean;
    private
      _id: TControlID;
      _bus: PMessageBus;
      _frame: TFrame;
      _parent: PControl;
      _backgroundColor: TColor;
      _backgroundStyle: EBackgroundStyle;
      _isEnabled: boolean;
      _alignment: EAlignment;
      _canvas: PCanvas;
      _isHidden: boolean;
    end;

implementation

  { TControl public }

  constructor TControl.init;
  begin
    inherited init;
    _id := '';
    _parent := nil;
    _bus := nil;
    _backgroundColor := DefaultColorScheme^.getColor(ECKPanelBackground);
    _backgroundStyle := EBackgroundStyleSolid;
    _isEnabled := true;
    _alignment := EAlignNone;
    _canvas := nil;
    with _frame, point, size do
    begin
      x := 0;
      y := 0;
      width := 75;
      height := 50;
    end;
    _isHidden := false;
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
  var
    mousePosition: PPoint;
    frame: TFrame;  
  begin
    case msg^.opcode of
      C_MSG_MOUSE_LEFT_DOWN:
      begin
        frame := getFrame^;
        getAbsolutePosition(frame.point);
        mousePosition := msg^.payload;
        if isPointInFrame(mousePosition, @frame) then
          sendMessage(C_MSG_CONTROL_CLICKED, getBus);
      end;
    end;
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

  procedure TControl.setId(id: TControlId);  
  begin
    _id := id;
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

  procedure TControl.setEnabled(enabled: boolean);
  begin
    _isEnabled := enabled;
    requestRedraw;
  end;

  function TControl.isEnabled: boolean;
  begin
    isEnabled := _isEnabled;
  end;

  function TControl.findControl(id: TControlId): PControl;
  begin
    if _id = id then
      findControl := @self
    else
      findControl := nil;
  end;

  procedure TControl.setAlignment(alignment: EAlignment);
  begin
    _alignment := alignment;
  end;

  function TControl.getAlignment: EAlignment;
  begin
    getAlignment := _alignment;
  end;

  procedure TControl.setCanvas(canvas: PCanvas);
  begin
    _canvas := canvas;
  end;

  function TControl.getCanvas: PCanvas;
  begin
    getCanvas := _canvas;
  end;

  procedure TControl.defaultDraw;
  begin
  end;

  procedure TControl.requestRedraw;
  begin
    sendMessage(C_MSG_CONTROL_REQUEST_REDRAW, _bus);
  end;

  procedure TControl.setHidden(hidden: boolean);
  var redraw: boolean;
  begin
    redraw := _isHidden = hidden;
    _isHidden := hidden;
    if redraw then requestRedraw;
  end;

  function TControl.isHidden: boolean;
  begin
    isHidden := _isHidden;
  end;

  { TControl private }

  { Other }

end.
