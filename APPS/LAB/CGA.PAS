uses
  xcrt;

(*
  This file puts pixels in 320x200 4 color mode (CGA)
  This video mode is packed. Each color is represented by 2 bits.
  One byte represents 4 colors.
  Pixels are ordered top to bottom, left to right

  Memory is interlaced. That means that there are 2 pages in memory, one
  for even rows and one for odd rows. the base memory addresses for these
  pages are $B800 and $BA00

  Mem[$B800:10] := $00; { black }
  Mem[$B800:11] := $40; { cyan }
  Mem[$B800:12] := $80; { magenta } 
  Mem[$B800:13] := $C0; { white }
*)

procedure setVideoMode;
begin
  { set CGA 320x200x16 color mode }
  asm
    mov ah, 0
    mov al, 4
    int 10h
  end;
end;

procedure setTextMode;
begin
  { return to text mode }
  asm
    mov ah, 0
    mov al, 3
    int 10h
  end;
end;

procedure putpixel(x, y, c: byte);
var
  pixelNumber, byteNumber: word;
  bitOffset: byte;
  base, offset: word;
begin 
  { calculate (y * 320) + x which is the pixel number  }
  { y * 320 = (y * 256) + (y * 64) = y shl 8 + y shl 6 }
  pixelNumber := y * 320 + x;

  { to get byte number, divide that by 4 since there are 4 pixels per byte }
  byteNumber := pixelNumber shr 2; 
  bitOffset := (3 - (pixelNumber and 3)) shl 1;

{
  write ('x:', x);
  write (' y:', y);
  write (' pixel:', pixelNumber);
  write (' byte:', byteNumber);
  write (' offset:', bitOffset);
  writeln;
}

  if (y and 1)<>0 then base := $ba00 else base := $b000;
  offset := (y shr 1) * 320 + byteNumber;

  Mem[base:offset] := 
    Mem[base:offset] 
{    and (not (3 shl (j shl 1)))  }
    or ((c and 3) shl bitOffset);
end;


var
  x, y: word;
begin
  setVideoMode;

  putpixel(0, 0, 1);
  putpixel(0, 1, 2);
  putpixel(0, 2, 1);
  putpixel(0, 3, 2);
  putpixel(0, 4, 1);
  putpixel(0, 5, 2);


(*
  mem[$b800:0] := 1 shl 6;
  mem[$ba00:0] := 2 shl 6;
  mem[$b800:320 shr 2] := 1 shl 6;
  mem[$ba00:320 shr 2] := 2 shl 6;
*)
  readkey;
  setTextMode;
end.