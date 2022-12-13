{
  UMouse Unit
  2022 LRT
}
unit
  UMouse;

interface

  uses
    consts, utils, types, locale, int33,
    uclasses, uobject, uexc, umsgs;

  type
    PMouse = ^TMouse;
    TMouse = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure reset;
      procedure show;
      procedure hide;
      procedure update;
      function isCursorVisible: boolean;
      function isLeftDown: boolean;
      function isRightDown: boolean;
      function getLastPosition: PPoint;
    private
      _defaultCursor: PMouseCursor;
      _waitCursor: PMouseCursor;
      _isVisible: boolean;
      _lastPosition: TPoint;
      _lastStatus: word;
    end;

  const
    { example alternative mouse graphics cursor }
    C_CURSOR_TRIANGLE: TMouseCursor = (
      screenMask: ( $7FFF, $3FFF, $1FFF, $0FFF, $07FF, $03FF, $3FFF, $7FFF,
                    $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF );
      cursorMask: ( $8000, $C000, $E000, $F000, $F800, $FC00, $C000, $8000,
                    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000 );
      hotX: 0;
      hotY: 0
    );

implementation

  { TMouse public }

  constructor TMouse.init;
  begin
    inherited init;
    _isVisible := false;
    _defaultCursor := @C_CURSOR_TRIANGLE;
    _waitCursor := nil;
    _lastPosition := C_POINT_ZERO;
    _lastStatus := 0;
    reset;
  end;

  destructor TMouse.done;
  begin
    inherited done;
  end;

  function TMouse.getClassName: string;
  begin
    getClassName := 'TMouse';
  end;

  function TMouse.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Mouse;
  end;

  procedure TMouse.reset;
  begin
    mouseReset;
    setGraphicsCursor(_defaultCursor^);
  end;

  procedure TMouse.show;
  begin
    if _isVisible then exit;
    showMouseCursor;
    _isVisible := true;
  end;

  procedure TMouse.hide;
  begin
    if not _isVisible then exit;
    hideMouseCursor;
    _isVisible := false;
  end;

  procedure TMouse.update;
  var
    delegate: PObject;
    position: TPoint;
    status: word;
  begin
    delegate := getDelegate;
    with position do
    begin
      getMouseStatus(word(x), word(y), status);   
      if delegate <> nil then    
      begin
        if (x <> _lastPosition.x) or (y <> _lastPosition.y) then
          sendMessageWithData(C_MSG_MOUSE_MOVEMENT, delegate, @position, sizeof(TPoint));
        if (_lastStatus and C_MOUSE_LEFT) > (status and C_MOUSE_LEFT) then 
          sendMessage(C_MSG_MOUSE_LEFT_UP, delegate);
        if (_lastStatus and C_MOUSE_LEFT) < (status and C_MOUSE_LEFT) then 
          sendMessage(C_MSG_MOUSE_LEFT_DOWN, delegate);
        if (_lastStatus and C_MOUSE_RIGHT) > (status and C_MOUSE_RIGHT) then 
          sendMessage(C_MSG_MOUSE_RIGHT_UP, delegate);
        if (_lastStatus and C_MOUSE_RIGHT) < (status and C_MOUSE_RIGHT) then 
          sendMessage(C_MSG_MOUSE_RIGHT_DOWN, delegate);
      end;    
    end;
    _lastPosition := position;
    _lastStatus := status;
  end;

  function TMouse.isCursorVisible: boolean;
  begin
    isCursorVisible := _isVisible;
  end;

  function TMouse.isLeftDown: boolean;
  begin
    isLeftDown := (_lastStatus and C_MOUSE_LEFT) <> 0;
  end;
  
  function TMouse.isRightDown: boolean;
  begin
    isRightDown := (_lastStatus and C_MOUSE_RIGHT) <> 0;
  end;

  function TMouse.getLastPosition: PPoint;
  begin
    getLastPosition := @_lastPosition;
  end;

  { TMouse private }

  { Other }

end.
