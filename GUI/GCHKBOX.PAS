{
  GChkbox Unit

  2022 LRT
}
unit
  GChkbox;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, umsgs,
    gclasses, gtypes, gcontrol, gmsgs;

  type
    PCheckbox = ^TCheckbox;
    TCheckbox = object (TControl)
    public
      { constructors and destructors}
      constructor init;
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      function isChecked: boolean;
      procedure setChecked(value: boolean);
      procedure receiveMessage(msg: PObjectMessage); virtual;
      { methods }
    private
      _checked: boolean;
    end;

implementation

  { TCheckbox public }

  constructor TCheckbox.init;
  begin
    inherited init;
    _checked := false;
  end;

  destructor TCheckbox.done;
  begin
    inherited done;
  end;

  function TCheckbox.getClassName: string;
  begin
    getClassName := 'TCheckbox';
  end;

  function TCheckbox.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Checkbox;
  end;

  function TCheckbox.isChecked: boolean;
  begin
    isChecked := _checked;
  end;

  procedure TCheckbox.setChecked(value: boolean);
  begin
    _checked := value;
  end;

  procedure TCheckbox.receiveMessage(msg: PObjectMessage);
  var
    mousePosition: PPoint;
    frame: TFrame;
  begin
    if isHidden then exit;
    if msg^.opcode = C_MSG_MOUSE_LEFT_DOWN then
    begin
      mousePosition := msg^.payload;
      frame := getFrame^;
      getAbsolutePosition(frame.point);
      if isPointInFrame(mousePosition, @frame) then
      begin
        _checked := not _checked;
        requestRedraw;
        sendMessage(C_MSG_CONTROL_CLICKED, getBus);
      end;
    end;
  end;

  { TCheckbox private }

  { Other }

end.
