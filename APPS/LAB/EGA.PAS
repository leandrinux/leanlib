uses
  xcrt;

begin
  
  { set EGA 320x200x16 color mode }
  asm
    mov ah, 0
    mov al, 0Dh
    int 10h
  end;

  readkey;

  { return to text mode }
  asm
    mov ah, 0
    mov al, 3
    int 10h
  end;
end.