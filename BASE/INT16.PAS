{
  INT 16 - Keyboard BIOS Services
  Built with info from https://stanislavs.org/helppc/int_16.html
  2022 LRT
}
unit
  int16;

interface

  const
    C_KEYBOARD_FLAG_RIGHT_SHIFT_PRESSED = 1;
    C_KEYBOARD_FLAG_LEFT_SHIFT_PRESSED  = 2;
    C_KEYBOARD_FLAG_CTRL_PRESSED        = 4;
    C_KEYBOARD_FLAG_ALT_PRESSED         = 8;
    C_KEYBOARD_FLAG_SCROLL_LOCK_ACTIVE  = 16;
    C_KEYBOARD_FLAG_NUM_LOCK_ACTIVE     = 32;
    C_KEYBOARD_FLAG_CAPS_LOCK_ACTIVE    = 64;
    C_KEYBOARD_FLAG_INSERT_ACTIVE       = 128;

  type
    TKeyboardRepeatDelay = 0..3;
    TKeyboardTypematicRate = 0..$1F;

  procedure waitKeypressAndRead(var scancode, character: char);
  function getKeystrokeStatus(var scancode, character: char): boolean;
  function readKeyboardFlags: byte;
  procedure setDefaultKeyboardTypematicRate;
  procedure setKeyboardTypematicRate(repeatDelay: TKeyboardRepeatDelay; rate: TKeyboardTypematicRate);

implementation

  procedure waitKeypressAndRead(var scancode, character: char); assembler;
  asm
    mov ah, 0
    int 16h
    les di, scancode
    mov [es:di], ah
    les di, character
    mov [es:di], al
  end;

  function getKeystrokeStatus(var scancode, character: char): boolean;
  var
    result: word;
  begin
    asm
      mov ah, 1
      int 16h
      mov result, ax
    end;
    scancode := chr(Hi(result));
    character := chr(Lo(result));
    getKeystrokeStatus := result <> 0;
  end;

  function readKeyboardFlags: byte;
  var
    result: byte;
  begin
    asm
      mov ah, 2
      int 16h
      mov result, al
    end;
    readKeyboardFlags := result;
  end;

  procedure setDefaultKeyboardTypematicRate; assembler;
  asm
    mov ah, 3
    mov al, 0
    int 16h
  end;

  procedure setKeyboardTypematicRate(repeatDelay: TKeyboardRepeatDelay; rate: TKeyboardTypematicRate); assembler;
  asm
    mov ah, 3
    mov al, 5
    mov bh, repeatDelay
    mov bl, rate
    int 16h
  end;

end.