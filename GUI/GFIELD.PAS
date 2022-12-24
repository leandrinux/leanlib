{
  GField Unit
  2022 LRT
}
unit
  GField;

interface

  uses
    ascii, consts, utils, uclasses, types, locale,
    uobject, uexc, umsgs, 
    gclasses, gtypes, gcontrol, gmsgs;

  type
    PTextField = ^TTextField;
    TTextField = object (TControl)
    public
      { constructors and destructors}
      constructor initWithId(id: TControlId);
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure receiveMessage(msg: PObjectMessage); virtual;
      { methods }
      function isFocused: boolean;
      procedure setText(text: string);
      function getText: string;
    private
      _isFocused: boolean;
      _text: string;
    end;

implementation

  { TTextField public }

  constructor TTextField.initWithId(id: TControlId);
  begin
    inherited initWithId(id);
    _isFocused := false;
    _text := '';
  end;

  destructor TTextField.done;
  begin
    inherited done;
  end;

  function TTextField.getClassName: string;
  begin
    getClassName := 'TTextField';
  end;

  function TTextField.getClassId: word;
  begin
    getClassId := C_CLASS_ID_TextField;
  end;

  procedure TTextField.receiveMessage(msg: PObjectMessage);
  var
    mousePosition: PPoint;
    frame: TFrame;
  begin
    frame := getFrame^;
    getAbsolutePosition(frame.point);
    mousePosition := msg^.payload;
    case msg^.opcode of 

      C_MSG_KEYBOARD_KEY_DOWN:
      begin
        if not isEnabled then exit;
        if not _isFocused then exit;
        case PChar(msg^.payload)^ of

          C_BACKSPACE: 
            if length(_text) > 0 then dec(_text[0]);

          C_ESC, C_CR: 
            _isFocused := false;

          else begin
            inc(_text[0]);
            _text[length(_text)] := PChar(msg^.payload)^;
          end;
        end; 
        sendMessage(C_MSG_CONTROL_REQUEST_REDRAW, getBus);
      end;

      C_MSG_MOUSE_LEFT_DOWN:  
      begin
        if not isEnabled then exit;
        if _isFocused then exit;
        if isPointInFrame(mousePosition, @frame) then 
        begin
          _isFocused := true;
          sendMessage(C_MSG_CONTROL_REQUEST_REDRAW, getBus);
          sendMessage(C_MSG_CONTROL_FOCUS_CHANGED, getBus);
        end;
      end;

      C_MSG_CONTROL_FOCUS_CHANGED: 
      begin
        if _isFocused and (msg^.sender <> @self) then
        begin
          _isFocused := false;
          sendMessage(C_MSG_CONTROL_REQUEST_REDRAW, getBus);
        end;
      end;

    end;
  end;

  function TTextField.isFocused: boolean;
  begin
    isFocused := _isFocused;
  end;

  procedure TTextField.setText(text: string);
  begin
    _text := text;
    sendMessage(C_MSG_CONTROL_REQUEST_REDRAW, getBus);
  end;

  function TTextField.getText: string;
  begin
    getText := _text;
  end;

  { TTextField private }

  { Other }

end.
