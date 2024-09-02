{
  INT 33 - Mouse pointer Services
  Built with info from https://stanislavs.org/helppc/int_33.html
  This library was tested with CuteMouse v2.1 beta 4 driver by Nagy Daniel
  which also provides a Wheel API
  2022 LRT
}
unit
  int33;

interface

  const
    C_MOUSE_LEFT   = $0001;
    C_MOUSE_RIGHT  = $0002;
    C_MOUSE_MIDDLE = $0004;
    C_MOUSE_WHEEL  = $FFFF;

  type

    { used to query press or release information }
    TButtonInfo = record
      count: word;        { number of presses/releases since last query }
      x, y: word;         { the mouse cursor x and y position }
      status: word;       { the current button status }
    end;

    {
      used to set the mouse graphics cursor
      screen  cursor result
      0       0      0 (black)
      0       1      1 (white)
      1       0      Bit not changed (transparent)
      1       1      Bit inverted
    }
    PMouseCursor = ^TMouseCursor;
    TMouseCursor = packed record
      screenMask: array[0..15] of word; { screen mask / AND mask }
      cursorMask: array[0..15] of word; { cursor mask / XOR mask }
      hotX: word;                       { cursor hotspot X coordinate (-16 to 16) }
      hotY: word;                       { cursor hotspot Y coordinate (-16 to 16) }
    end;

  { *** int 33h services ************************************************** }

  { initializes the mouse driver }
  procedure mouseReset;

  {
    increments the mouse visibility accumulator
    (shows the cursor on screen if above zero)
  }
  procedure showMouseCursor;

  {
    decrements the mouse visibility accumulator
    (hides the cursor on screen if below zero)
  }
  procedure hideMouseCursor;

  {
    returns the mouse cursor position and the status of its buttons
  }
  procedure getMouseStatus(var x, y:word; var status: word);

  {
    sets the position of the mouse cursor
  }
  procedure setMousePosition(x, y: word);

  {
    returns mouse button press information
  }
  procedure getPressInfo(button: word; var info:TButtonInfo);

  {
    returns mouse button release information
  }
  procedure getReleaseInfo(button: word; var info:TButtonInfo);

  {
    sets the minimum and maximum values for the mouse horizontal movement
  }
  procedure setHorizontalRange(min, max: word);

  {
    sets the minimum and maximum values for the mouse vertical movement
  }
  procedure setVerticalRange(min, max: word);

  {
    sets the graphics mouse cursor
  }
  procedure setGraphicsCursor(var cursor: TMouseCursor);

  {
    sets a software text cursor. front and back are the colors,
    char is the character that represents the cursor
  }
  procedure setTextCursor(front, back: byte; character: char);

  {
    reads the mouse motion counters.
    returns values in mickeys (a unit of measurement for mouse movement)
    for both horizontal and vertical axes) as signed 16 bit integers
  }
  procedure getMotionCounters(var h, v: integer);

  {
    sets the ratio between physical cursor movement (mickeys) and
    screen coordinate changes.
  }
  procedure setMickeysPer8Pixels(mx, my: word);

  {
    returns the number of buttons available
  }
  function getButtonCount: byte;

  {
    returns true if the mouse device is available for use
  }
  function isMouseAvailable: boolean;

  {
    returns true if a mouse wheel is present
  }
  function isWheelSupported: boolean;

  { *** useful functions ************************************************** }

  {
    returns true if the specified mouse button is pressed
  }
  function mouseButtonDown(button: word): boolean;

implementation

  var
    mButtonCount: byte;

  procedure mouseReset;
  var
    driverInstalled: word;
    buttonCount: word;
  begin
    asm
      mov ax, 0
      int 33h
      mov driverInstalled, ax
      mov buttonCount, bx
    end;
    if driverInstalled <> $FFFF then
      mButtonCount := 0
    else
      mButtonCount := Lo(buttonCount);
  end;

  procedure showMouseCursor; assembler;
  asm
    mov ax, 1
    int 33h
  end;

  procedure hideMouseCursor; assembler;
  asm
    mov ax, 2
    int 33h
  end;

  procedure getMouseStatus(var x, y:word; var status: word);
  var
    px, py, s: word;
  begin
    asm
      mov ax, 3
      int 33h
      mov px, cx
      mov py, dx
      mov s, bx
    end;
    x := px;
    y := py;
    status := s;
  end;

  function isMouseAvailable: boolean;
  begin
    isMouseAvailable := mButtonCount > 0;
  end;

  procedure setMousePosition(x, y: word);
  begin
    asm
      mov ax, 4
      mov cx, x
      mov dx, y
      int 33h
    end;
  end;

  procedure getInfo(cmd: word; button: word; var info:TButtonInfo);
  var
    count, px, py, status: word;
  begin
    asm
      mov ax, cmd
      mov bx, button
      int 33h
      mov count, bx
      mov px, cx
      mov py, dx
      mov status, ax
    end;
    info.count := count;
    info.x := px;
    info.y := py;
    info.status := status;
  end;

  procedure getPressInfo(button: word; var info:TButtonInfo);
  begin
    GetInfo(5, button, info);
  end;

  procedure getReleaseInfo(button: word; var info:TButtonInfo);
  begin
    GetInfo(6, button, info);
  end;

  procedure setRange(cmd, min, max: word);
  begin
    asm
      mov ax, cmd
      mov cx, min
      mov dx, max
      int 33h
    end;
  end;

  procedure setHorizontalRange(min, max: word);
  begin
    SetRange(7, min, max);
  end;

  procedure setVerticalRange(min, max: word);
  begin
    SetRange(8, min, max);
  end;

  procedure setGraphicsCursor(var cursor: TMouseCursor);
  var x, y: word;
  begin
    x := cursor.hotX;
    y := cursor.hotY;
    asm
      mov ax, 0009h
      mov bx, x
      mov cx, y
      les dx, cursor
      int 33h
    end;
  end;

  procedure setTextCursor(front, back: byte; character: char);
  var color: byte;
  begin
    color := (back shl 4) or front;
    asm
      mov ax, $0A
      mov bx, $00 { software cursor }
      mov cx, $00 { screen mask value }
      mov dh, color { front and back colors }
      mov dl, character { character to use }
      int 33h
    end;
  end;

  procedure getMotionCounters(var h, v: integer);
  var hm, vm: word;
  begin
    asm
      mov ax, 0Bh
      int 33h
      mov hm, cx
      mov vm, dx
    end;
    h := hm;
    v := vm;
  end;

  procedure setMickeysPer8Pixels(mx, my: word); assembler;
  asm
    mov ax, 0Fh
    mov cx, mx { default mickeys per 8 pixels is 8  }
    mov dx, my { default mickeys per 8 pixels is 16 }
    int 33h
  end;

  function getButtonCount: byte;
  begin
    GetButtonCount := mButtonCount;
  end;

  function isWheelSupported: boolean;
  var
    signature: word;
    capabilities: word;
  begin
    asm
      mov ax, 11h
      int 33h
      mov signature, ax
      mov capabilities, cx
    end;
    isWheelSupported := (signature = $574D) and ((capabilities and 1) = 1);
  end;

  function mouseButtonDown(button: word): boolean;
  var
    x, y, status: word;
  begin
    getMouseStatus(x, y, status);
    mouseButtonDown := (status and button) <> 0;
  end;

begin
  mButtonCount := 0;
end.
