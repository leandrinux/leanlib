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
    ECursorType = (
      ECursorDefault,
      ECursorWait
    );

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
      procedure selectCursor(cursorType: ECursorType);
      procedure changeCursor(cursorType: ECursorType; cursor: PMouseCursor);
      function isCursorVisible: boolean;
      function isLeftDown: boolean;
      function isRightDown: boolean;
      function getPosition: PPoint;
    private
      _cursors: array [ECursorType] of PMouseCursor;
      _isVisible: boolean;
      _lastPosition: TPoint;
      _lastStatus: word;
    end;

  var
    Mouse: PMouse;

implementation

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

    C_CURSOR_HOURGLASS: TMouseCursor = (
      screenMask: ( $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF,
                    $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF );
      cursorMask: ( $FFF0, $8010, $8010, $E070, $F0F0, $79E0, $3FC0, $1F80,
                    $1080, $2640, $4020, $8010, $8610, $8F10, $9F90, $FFF0 );
      hotX: 5;
      hotY: 6
    );

  { TMouse public }

  constructor TMouse.init;
  begin
    inherited init;
    _isVisible := false;
    _cursors[ECursorDefault] := @C_CURSOR_TRIANGLE;
    _cursors[ECursorWait] := @C_CURSOR_HOURGLASS;
    _lastPosition := C_POINT_ZERO;
    _lastStatus := 0;
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
    setGraphicsCursor(_cursors[ECursorDefault]^);
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
    if not _isVisible then exit;
    delegate := getDelegate;
    with position do
    begin
      getMouseStatus(word(x), word(y), status); 
      x := x shr 1; { FIX THIS - it will only work for 320 x 200 }  
      if delegate <> nil then    
      begin
        if (x <> _lastPosition.x) or (y <> _lastPosition.y) then
          sendMessageWithData(C_MSG_MOUSE_MOVEMENT, delegate, @position, sizeof(TPoint));
        if (_lastStatus and C_MOUSE_LEFT) > (status and C_MOUSE_LEFT) then 
          sendMessageWithData(C_MSG_MOUSE_LEFT_UP, delegate, @position, sizeof(TPoint));
        if (_lastStatus and C_MOUSE_LEFT) < (status and C_MOUSE_LEFT) then 
          sendMessageWithData(C_MSG_MOUSE_LEFT_DOWN, delegate, @position, sizeof(TPoint));
        if (_lastStatus and C_MOUSE_RIGHT) > (status and C_MOUSE_RIGHT) then 
          sendMessageWithData(C_MSG_MOUSE_RIGHT_UP, delegate, @position, sizeof(TPoint));
        if (_lastStatus and C_MOUSE_RIGHT) < (status and C_MOUSE_RIGHT) then 
          sendMessageWithData(C_MSG_MOUSE_RIGHT_DOWN, delegate, @position, sizeof(TPoint));
      end;    
    end;
    _lastPosition := position;
    _lastStatus := status;
  end;

  procedure TMouse.changeCursor(cursorType: ECursorType; cursor: PMouseCursor);
  begin
    _cursors[cursorType] := cursor;
  end;

  procedure TMouse.selectCursor(cursorType: ECursorType);
  begin
    setGraphicsCursor(_cursors[cursorType]^);    
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

  function TMouse.getPosition: PPoint;
  begin
    getPosition := @_lastPosition;
  end;

  { TMouse private }

  { Other }
begin
  Mouse := new(PMouse, init);
end.
