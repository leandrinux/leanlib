uses
  xcrt, int10;

procedure setColor(color: byte);
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
end;

{ y * (64+16) = 64y+16y }

procedure setPixel(x, y: word);
var
  w: word;
  offset: word;
  value: byte;
begin
  w := 640;
  offset := (x shr 3) + (y shr 3) shl 4 + (y shr 3) shl 6;
  value := $80 shr (x and 7);
  Mem[$A000:offset] := Mem[$A000:offset] or value;
end;

var
  x, y: word;
begin
  setVideoMode(C_VIDMODE_EGA_640x350_16);
  setColor(9);
  for y := 0 to 50 do 
    for x := 0 to 100 do 
    begin
      setPixel(x, y);
    end;
  readkey;
  setVideoMode(C_VIDMODE_CGA_T_80x25_16);
end.