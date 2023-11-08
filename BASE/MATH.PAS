{
  Math Unit
  All things about numbers
  2022 LRT
}
unit
  math;

interface

  uses
    types;

  const
    PI_2 = 6.28318530718;

  function pow(value, exp: byte): longint;
  function maxword(a, b:word): word;
  function minword(a, b:word): word;
  function maxint(a, b:integer): integer;
  function minint(a, b:integer): integer;
  function maxlong(a, b:longint): longint;
  function minlong(a, b:longint): longint;
  function loword(l: longint): word;
  function hiword(l: longint): word;
  procedure swapint(var first, second : integer);
  function incptr(p: pointer; count: word): pointer;
  function perimeter(radius: real): real;
  procedure createCirclePoints(radius: word; var points: PPoint; var count, byteSize: word);

implementation

  function pow(value, exp: byte): longint;
  var
    res: longint;
    i: byte;
  begin
    res := 1;
    for i := 1 to exp do res := res * value;
    pow := res;
  end;

  function maxword(a, b:word): word;
  begin
    if a>b then maxword := a else maxword := b;
  end;

  function minword(a, b:word): word;
  begin
    if a<b then minword := a else minword := b;
  end;

  function maxint(a, b:integer): integer;
  begin
    if a>b then maxint := a else maxint := b;
  end;

  function minint(a, b:integer): integer;
  begin
    if a<b then minint := a else minint := b;
  end;

  function maxlong(a, b:longint): longint;
  begin
    if a>b then maxlong := a else maxlong := b;
  end;

  function minlong(a, b:longint): longint;
  begin
    if a<b then minlong := a else minlong := b;
  end;

  function loword(l: longint): word;
  begin
    loword := l and $0000FFFF;
  end;

  function hiword(l: longint): word;
  begin
    hiword := l shr 16;
  end;

  procedure swapint(var first, second : integer);
  var
    temp : Integer;
  begin
    temp := first;
    first := Second;
    second := temp;
  end;

  function incptr(p: pointer; count: word): pointer;
  begin
    incptr := ptr(seg(p^), ofs(p^) + count);
  end;

  function perimeter(radius: real): real;
  begin
    perimeter := PI_2 * radius;
  end;

  procedure createCirclePoints(radius: word; var points: PPoint; var count, byteSize: word);
  var
    px, py, d: integer;
    dE, dSE: integer;
    p: ^integer;

    procedure add(x, y: integer);
    begin
      p^ := x; inc(p);
      p^ := y; inc(p);
    end; 

  begin
    byteSize := sizeof(TPoint) * round(Math.perimeter(radius));
    GetMem(p, byteSize);
    points := PPoint(p);
    px := 0;
    py := radius;
    d := 1 - radius;
    dE := 3;
    dSE := -(radius shl 1) + 5;
    
    add(0, -py);
    add(0, +py);
    add(+py, -px);
    add(-py, +px);
    count := 4;    
    while py>px do
    begin
      if d<0 then
      begin
        d := d + dE;
        dE := dE + 2;
        dSE := dSE + 2;
        px := px + 1;
      end else
      begin
        d := d + dSE;
        dE := dE + 2;
        dSE := dSE + 4;
        px := px + 1;
        py := py - 1;
      end;
      add(+px, -py);
      add(-px, +py);
      add(-px, -py);
      add(+px, +py);
      add(+py, -px);
      add(-py, +px);
      add(-py, -px);
      add(+py, +px);
      inc(count, 8);
    end;
  end;

end.