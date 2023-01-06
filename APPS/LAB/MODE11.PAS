uses
  xcrt, int10;

procedure setPixel(x, y: word; color: byte);
const
  SC_MAP_MASK = 2;
  GC_INDEX = $3ce;
  SC_INDEX = $3c4;
var
  idx: byte;
  setting: byte;
begin
  idx := SC_MAP_MASK;
  setting := color;
  asm
    mov     dx,SC_INDEX
    mov     al,idx
    out     dx,al
    inc     dx
    mov     al,setting
    out     dx,al
    dec     dx
  end;

  Mem[$A000:0] := $FF;
end;

begin
  setVideoMode(C_VIDMODE_EGA_640x350_16);
  setPixel(0, 0, 9);
  readkey;
  setVideoMode(C_VIDMODE_CGA_T_80x25_16);
end.