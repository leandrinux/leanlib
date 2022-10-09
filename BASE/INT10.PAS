{
  INT 10 - Video BIOS Services
  Built with info from https://stanislavs.org/helppc/int_10.html
  2022 LRT
}
unit
  int10;

interface

  const

    { video modes compatible with the setVideoMode proc }
    C_VIDMODE_CGA_T_40x25_BW   = $00;
    C_VIDMODE_CGA_T_40x25_16   = $01;
    C_VIDMODE_CGA_T_80x25_BW   = $02;
    C_VIDMODE_CGA_T_80x25_16   = $03;
    C_VIDMODE_CGA_G_320x200_4  = $04;
    C_VIDMODE_CGA_G_320x200_BW = $05;
    C_VIDMODE_CGA_G_640x200_BW = $06;
    C_VIDMODE_MDA_80x25_MONO   = $07;
    C_VIDMODE_PCJR_G_160x200   = $08;
    C_VIDMODE_PCJR_G_320x200   = $09;
    C_VIDMODE_PCJR_G_640x200   = $0A;
    C_VIDMODE_EGA_320x200_16   = $0D;
    C_VIDMODE_EGA_640x200_16   = $0E;
    C_VIDMODE_EGA_640x350_BW   = $0F;
    C_VIDMODE_EGA_640x350_16   = $10;
    C_VIDMODE_VGA_640x480_BW   = $11;
    C_VIDMODE_VGA_640x480_16   = $12;
    C_VIDMODE_VGA_320x200_256  = $13;

    { return values for getVideoDisplayCombination }
    C_DISPLAY_CODE_UNRECOGNIZED = $FF;
    C_DISPLAY_CODE_NO_DISPLAY   = $00;
    C_DISPLAY_CODE_MDA_MONO     = $01;
    C_DISPLAY_CODE_CGA_COLOR    = $02;
    C_DISPLAY_CODE_EGA_COLOR    = $04;
    C_DISPLAY_CODE_EGA_MONO     = $05;
    C_DISPLAY_CODE_PGA          = $06;
    C_DISPLAY_CODE_VGA_MONO     = $07;
    C_DISPLAY_CODE_VGA_COLOR    = $08;
    C_DISPLAY_CODE_MCGA_COLOR_D = $0A;
    C_DISPLAY_CODE_MCGA_MONO    = $0B;
    C_DISPLAY_CODE_MCGA_COLOR_A = $0C;

  { *** int 10h services ************************************************** }

  { sets the specified video mode (text, graphics, Herc, CGA, EGA, VGA }
  procedure setVideoMode(mode: byte);

  { gets the current video mode value }
  function getVideoMode: byte;

  {
    video display combination (VGA)
    returns the active and inactive video displays (for instance, if you
    have a VGA and a Hercules card installed). function returns true
    if the function was successful. returns false if this info is not
    available (probably because you don't have a VGA)
  }
  function getVideoDisplayCombination(var active, inactive: byte): boolean;

  {
    set block of DAC color registers
    sets the current palette, starting from a color index, for as many
    colors as specifies, using a given table of color values
  }
  procedure setDACColorRegistersBlock(colors: pointer; count: word; fromIndex: word);

  { *** useful functions ************************************************** }

  { for VGA displays, it sets the 80x50 special text video mode }
  procedure set50LineTextMode;

  { shows or hides the cursor in text mode }
  procedure showTextCursor(visible: boolean);

implementation

  procedure setVideoMode(mode: byte); assembler;
  asm
    mov ah, 0
    mov al, mode
    int 10h
  end;

  function getVideoMode: byte;
  var
    mode: byte;
  begin
    asm
      mov ah, $0F
      int $10
      mov mode, al
    end;
    GetVideoMode := mode;
  end;

  function getVideoDisplayCombination(var active, inactive: byte): boolean;
  var
    result: byte;
  begin
    asm
      mov ah, $1A
      mov al, 0
      int $10
      mov result, al
      les di, active
      mov [es:di], bl
      les di, inactive
      mov [es:di], bh
    end;
    getVideoDisplayCombination := result = $1A;
  end;

  procedure setDACColorRegistersBlock(colors: pointer; count: word; fromIndex: word); assembler;
  asm
    mov ax, $1012      { al = 12 set block of DAV color registers }
    mov bx, fromIndex  { bx = first index of block }
    mov cx, count      { cx = number of colors to set }
    les dx, colors     { es:dx pointer to table of color values to set }
    int 10h
  end;

  { *** useful functions ************************************************** }

  procedure set50LineTextMode; assembler;
  asm
    mov ax, $1202
    mov bl, $30
    int $10     {set 400 scan lines}

    mov ax, 3
    int $10     {set Text mode}

    mov ax, $1112
    mov bl, 0
    int $10     {load 8x8 font to page 0 block}
  end;

  procedure showTextCursor(visible: boolean);
  begin
    asm
      mov ah, 3
      mov bx, 0
      int $10
      cmp visible, 0
      jnz @hide
      or ch, $20
      jmp @set

      @hide:
        and ch, 255-$20

      @set:
        mov ah, 1
        mov bx, 0
        int $10
    end;
  end;

end.