{
  GButton Unit
  2022 LRT
}
unit
  GButton;

interface

  uses
    xcrt, consts, utils, types, locale,
    uclasses, uobject, uexc, umsgs,
    gclasses, gtypes, gcontrol, gmsgs;

  type
    EButtonState = (
      EButtonStateUp,
      EButtonStateDown
    );

    TButtonCaption = string32;

    PButton = ^TButton;
    TButton = object (TControl)
    public
      { constructors and destructors}
      constructor initWithId(id: TControlId);
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure receiveMessage(msg: PObjectMessage); virtual;
      { methods }
      function getState: EButtonState;
      procedure setState(state: EButtonState);
      function getCaption: TButtonCaption;
      procedure setCaption(caption: TButtonCaption);
    private
      _state: EButtonState;
      _caption: TButtonCaption;
    end;

implementation

  { TButton public }

  constructor TButton.initWithId(id: TControlId);
  begin
    inherited initWithId(id);
    _state := EButtonStateUp;
    _caption := '';
  end;

  destructor TButton.done;
  begin
    inherited done;
  end;

  function TButton.getClassName: string;
  begin
    getClassName := 'TButton';
  end;

  function TButton.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Button;
  end;

  procedure TButton.receiveMessage(msg: PObjectMessage);
  var
    mousePosition: PPoint;
    frame: TFrame;
  begin
    case msg^.opcode of
      C_MSG_MOUSE_LEFT_UP, C_MSG_MOUSE_LEFT_DOWN: 
      begin
        frame := getFrame^;
        getAbsolutePosition(frame.point);
        mousePosition := msg^.payload;
        if (_state = EButtonStateUp) 
           and (msg^.opcode = C_MSG_MOUSE_LEFT_DOWN) 
           and isPointInFrame(mousePosition, @frame) then 
        begin
          _state := EButtonStateDown;
          sendMessage(C_MSG_CONTROL_REQUEST_REDRAW, getBus);
        end else
          if (_state = EButtonStateDown) and (msg^.opcode = C_MSG_MOUSE_LEFT_UP) then
          begin
            _state := EButtonStateUp;
            sendMessage(C_MSG_CONTROL_REQUEST_REDRAW, getBus);
            if isPointInFrame(mousePosition, @frame) then
              sendMessage(C_MSG_BUTTON_CLICK, getBus);
          end;
      end;
    end;

{
    if msg^.opcode = C_MSG_MOUSE_ACTIVITY then
    begin
      mouseActivity := PMouseActivity(msg^.payload);
      if (mouseActivity^.event = EMouseEventLeftDown) and (_state = EButtonStateUp) then
      begin 
        _state := EButtonStateDown;
        sendMessage(C_MSG_CONTROL_REQUEST_REDRAW, getParent);
      end else if (mouseActivity^.event = EMouseEventLeftUp) and (_state = EButtonStateDown) then
      begin
        _state := EButtonStateUp;
        sendMessage(C_MSG_CONTROL_REQUEST_REDRAW, getParent);
      end;
    end;
  }
  end;

  function TButton.getState: EButtonState;
  begin
    getState := _state;
  end;

  procedure TButton.setState(state: EButtonState);
  begin
    _state := state;
  end;

  function TButton.getCaption: TButtonCaption;
  begin
    getCaption := _caption;
  end;

  procedure TButton.setCaption(caption: TButtonCaption);
  begin
    _caption := caption;
  end;

  { TButton private }

  { Other }

end.
