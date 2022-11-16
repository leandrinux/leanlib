{
  CRT Unit
  A smaller and hopefully less buggy replacement for Borland's CRT unit
  2022 LRT
}
unit
  xcrt;

interface

  const
    C_TICK_DURATION = 54.9254;
    C_TICKS : ^longint = ptr($0040, $006C);

  procedure sound(freq: word);
  procedure nosound;
  procedure delay(mseg: word);
  procedure clrscr;
  function keypressed: boolean;
  function readkey: char;
  procedure beep;
  procedure gotoxy(x, y: byte);

implementation

  procedure sound(freq: word);
  begin
    freq := $001234DC div freq;
    asm
      { prepare timer to start generating sound }
      mov al, 182
      out 43h, al

      { TONEOUT = word: 1193180 / frequency }
      { send low byte to port 42h }
      mov ax, freq
      out 42h, al

      mov al, ah
      out 42h, al
      { send high byte to port 42h }

      { get current value of port 61h }
      in al, 61h
      or al, 3          { set lowest two bits of 61h "on" -- activate speaker }
      out 61h, al       { rewrite to port 61h }
    end;
  end;

  procedure nosound;
  begin
    asm
      in al, 61h        { set lowest two bits of 61h "off" -- deactive speaker }
      and al, 252       { this line turns the lowest two bits "off" }
      out 61h, al
    end;
  end;

  procedure delay(mseg: word); assembler;
  asm
    mov ax, 1000
    mul mseg
    mov cx, dx
    mov dx, ax
    mov ah, $86
    int $15
  end;

  procedure clrscr;
  var
    w: word;
    p: ^word;
  begin
    p := Ptr($B800, 0);
    for w := 1999 downto 0 do
    begin
      p^ := $0700;
      inc(p);
    end;
    asm
      mov dx, 0
      xor bh, bh
      mov ah, 2;
      int $10
    end;
  end;

  function keypressed: boolean; assembler;
  asm
    mov ah, 1
    int $16
    mov ax, 0
    jz @1
    inc ax
    @1:
  end;

  function readkey: char; assembler;
  asm
    mov ah, 0
    int $16
  end;

  procedure beep;
  begin
    sound(500);
    delay(100);
    nosound;
  end;

  procedure gotoxy(x, y: byte);
  begin
    asm
      mov dh, y
      mov dl, x
      xor bh, bh
      mov ah, 2;
      int $10
    end;
  end;

end.