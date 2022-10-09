{
  Math Unit
  All things about numbers
  2022 LRT
}
unit
  math;

interface

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

end.