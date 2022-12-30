{
  GField Unit
  2022 LRT
}
unit
  GField;

interface

  uses
    ascii, consts, utils, uclasses, types, locale,
    uobject, uexc, umsgs, ufont, usysfont,
    gclasses, gtypes, gcontrol, gmsgs;

  type
    TTextValue = string32;
    TPlaceholderText = string32;

    PTextField = ^TTextField;
    TTextField = object (TControl)
    public
      { constructors and destructors}
      constructor init;
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure receiveMessage(msg: PObjectMessage); virtual;
      procedure setEnabled(enabled: boolean); virtual;
      { methods }
      function isFocused: boolean;
      procedure setText(text: TTextValue);
      function getText: TTextValue;
      procedure setPlaceholder(placeholder: TPlaceholderText);
      function getPlaceholder: TPlaceholderText;
      procedure setFont(font: PFont);
      function getFont: PFont;
    private
      _isFocused: boolean;
      _text: TTextValue;
      _previousText: TTextValue;
      _placeholder: TPlaceholderText;
      _font: PFont;
    end;

implementation

  const
    C_DEFAULT_TEXTFIELD_WIDTH = 200;
    C_DEFAULT_TEXTFIELD_HEIGHT = 14;

  { TTextField public }

  constructor TTextField.init;
  begin
    inherited init;
    _isFocused := false;
    _text := '';
    _placeholder := '';
    with getFrame^, point, size do
    begin
      width := C_DEFAULT_TEXTFIELD_WIDTH;
      height := C_DEFAULT_TEXTFIELD_HEIGHT;
    end;
    _font := SystemFont;
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

          C_ESC:
          begin
            _isFocused := false;
            _text := _previousText;
          end;
          
          C_CR:
          begin
            _isFocused := false;
          end;

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
          _previousText := _text;
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

  procedure TTextField.setEnabled(enabled: boolean);
  begin
    if _isFocused and not enabled then _isFocused := false;
    inherited setEnabled(enabled);
  end;

  function TTextField.isFocused: boolean;
  begin
    isFocused := _isFocused;
  end;

  procedure TTextField.setText(text: TTextValue);
  begin
    _text := text;
    sendMessage(C_MSG_CONTROL_REQUEST_REDRAW, getBus);
  end;

  function TTextField.getText: TTextValue;
  begin
    getText := _text;
  end;

  procedure TTextField.setPlaceholder(placeholder: TPlaceholderText);
  begin
    _placeholder := placeholder;
  end;

  function TTextField.getPlaceholder: TPlaceholderText;
  begin
    getPlaceholder := _placeholder;
  end;

  procedure TTextField.setFont(font: PFont);
  begin
    _font := font;
  end;

  function TTextField.getFont: PFont;
  begin
    getFont := _font;
  end;

  { TTextField private }

  { Other }

end.
