{
  GButton Unit
  2022 LRT
}
unit
  GButton;

interface

  uses
    xcrt, consts, utils, types, locale,
    uclasses, uobject, uexc, umsgs, utrender, ufont, usysfont,
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
      constructor init;
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
      procedure adjustSizeToText;
      procedure setFont(font: PFont);
      function getFont: PFont;
    private
      _state: EButtonState;
      _caption: TButtonCaption;
      _font: PFont;
    end;

implementation

  const
    C_DEFAULT_BUTTON_WIDTH = 75;
    C_DEFAULT_BUTTON_HEIGHT = 14;
    C_TEXT_HPADDING = 14;

  { TButton public }

  constructor TButton.init;
  begin
    inherited init;
    _state := EButtonStateUp;
    _caption := '';
    with getFrame^, point, size do
    begin
      x := 0;
      y := 0;
      width := C_DEFAULT_BUTTON_WIDTH;
      height := C_DEFAULT_BUTTON_HEIGHT;
    end;
    _font := SystemFont;
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
    if isHidden then exit;
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
          requestRedraw;
        end else
          if (_state = EButtonStateDown) and (msg^.opcode = C_MSG_MOUSE_LEFT_UP) then
          begin
            _state := EButtonStateUp;
            requestRedraw;
            if isPointInFrame(mousePosition, @frame) then
              sendMessage(C_MSG_CONTROL_CLICKED, getBus);
          end;
      end;
    end;
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
    requestRedraw;
  end;

  procedure TButton.adjustSizeToText;
  var
    tr: PTextRenderer;
  begin
    tr := new(PTextRenderer, init);
    tr^.setFont(_font);
    tr^.getTextSize(_caption, @(getFrame^.size));
    with getFrame^.size do
    begin
      inc(width, C_TEXT_HPADDING);
      height := C_DEFAULT_BUTTON_HEIGHT;
    end;
    tr^.release;
  end;

  procedure TButton.setFont(font: PFont);
  begin
    _font := font;
  end;

  function TButton.getFont: PFont;
  begin
    getFont := _font;
  end;

  { TButton private }

  { Other }

end.
