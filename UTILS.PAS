{
  Utils Unit
  Stuff that doesn't fit anywhere else: type conversions, compare functions
  2022 LRT
}
unit
  utils;

interface

  uses
    consts, types, locale;

  { basic data types to string }
  function boolToStr(b: boolean): string5;
  function longToStr(i: longint): string11;
  function intToStr(i: integer): string6;

  { numbers to hexadecimal string }
  function byteToHex(i: byte): string2;
  function wordToHex(i: word): string4;
  function longToHex(i: longint): string8;
  function hexToByte(s: string2): byte;
  function hexToWord(s: string4): word;
  function hexToLong(s: string8): longint;

  { pointer to string in segment:offset format }
  function ptrToStr(p: pointer): string9;

  { string to number }
  function strToInt(s: string): integer;

  { comparison functions }
  function compareBuffers(a, b: pchar; size: word): ECompareResult;
  function compareLong(a, b: pointer): ECompareResult;
  function compareStr(a, b: pointer): ECompareResult;

  { file path parsing }
  function getFilename(path: string; extension: boolean): string;

  { converts record types to readable strings}
  function sizeToStr(size: PSize): string;
  function pointToStr(point: PPoint): string;
  function frameToStr(frame: PFrame): string;
  function isPointInFrame(p: PPoint; f: PFrame): boolean;

  function lowcase(ch: char): char;

implementation

  const
    C_HEX_DIGITS: array [0..15] of char = '0123456789ABCDEF';

  function boolToStr(b: boolean): string5;
  begin
    if b then
      boolToStr := S_TRUE
    else
      boolToStr := S_FALSE;
  end;

  function longToStr(i: longint): string11;
  var s: string;
  begin
    Str(i, s);
    LongToStr := s;
  end;

  function intToStr(i: integer): string6;
  var
    s: string6;
  begin
    Str(i, s);
    IntToStr := s;
  end;

  function byteToHex(i: byte): string2;
  begin
    byteToHex := C_HEX_DIGITS[i shr 4] + C_HEX_DIGITS[i and $0F];
  end;

  function wordToHex(i: word): string4;
  begin
    wordToHex := ByteToHex(hi(i)) + ByteToHex(lo(i));
  end;

  function longToHex(i: longint): string8;
  begin
    LongToHex := ByteToHex(i shr 24) +
                 ByteToHex((i and $00FF0000) shr 16) +
                 ByteToHex((i and $0000FF00) shr 8) +
                 ByteToHex(i and $000000FF);
  end;

  function hexToByte(s: string2): byte;
  begin
    hexToByte := hexToLong(s) and $FF;
  end;

  function hexToWord(s: string4): word;
  begin
    hexToWord := hexToLong(s) and $FFFF;
  end; 

  function hexToLong(s: string8): longint;
  var
    i: byte;
    c: char;
    v: longint;
  begin
    v := 0;
    for i := 1 to length(s) do
    begin
      v := v shl 4;
      c := upcase(s[i]);
      if (c >= '0') and (c <= '9') then 
        v := v or (ord(c) - ord('0'))
      else  if (c >= 'A') and (c <= 'F') then
        v := v or (10 + ord(c) - ord('A'));
    end;
    hexToLong := v;
  end;

  function ptrToStr(p: pointer): string9;
  begin
    if p = nil then 
      ptrToStr := 'nil'
    else
      ptrToStr := WordToHex(Seg(p^)) + ':' + WordToHex(Ofs(p^));
  end;

  function strToInt(s: string): integer;
  var i, c: integer;
  begin
    Val(s, i, c);
    StrToInt := i;
  end;

  function compareBuffers(a, b: pchar; size: word): ECompareResult;
  begin
    while (size>0) and (a^=b^) do
    begin
      inc(a);
      inc(b);
      dec(size);
    end;
    if size=0 then
      compareBuffers := ECompareEqual
    else
      if a^<b^ then
        compareBuffers := ECompareLesser
      else
        compareBuffers := ECompareGreater;
  end;

  function compareLong(a, b: pointer): ECompareResult;
  begin
    if plong(a)^ > plong(b)^ then compareLong := ECompareGreater else
      if plong(a)^ < plong(b)^ then compareLong := ECompareLesser else
        compareLong := ECompareEqual;
  end;

  function compareStr(a, b: pointer): ECompareResult;
  begin
    if pstr(a)^ > pstr(b)^ then compareStr := ECompareGreater else
      if pstr(a)^ < pstr(b)^ then compareStr := ECompareLesser else
        compareStr := ECompareEqual;
  end;

  function getFilename(path: string; extension: boolean): string;
  var
    i: byte;
    s: string;
  begin
    i := length(path);
    if not extension then dec(i, 4);
    s := '';
    while path[i] <> C_FILE_PATH_SEPARATOR do
    begin
      s := path[i] + s;
      dec(i);
    end;
    getFilename := s;
  end;

  function sizeToStr(size: PSize): string;
  begin
    with size^ do 
      sizeToStr := 'W:' + inttostr(width) + ', H:' + inttostr(height);
  end;

  function pointToStr(point: PPoint): string;
  begin
    with point^ do 
      pointToStr := 'X:' + inttostr(x) + ', Y:' + inttostr(y);
  end;

  function frameToStr(frame: PFrame): string;
  begin
    with frame^ do
      frameToStr := pointToStr(@point) + ', ' + sizeToStr(@size);
  end;

  function isPointInFrame(p: PPoint; f: PFrame): boolean;
  begin
    with f^, point, size do
      isPointInFrame := (p^.x >= x) and (p^.x <= (x+width)) and (p^.y >= y) and (p^.y <= (y+height));
  end;

  function lowcase(ch: char): char;
  begin
    if ch in ['A'..'Z'] then 
      lowcase := chr(ord(ch) + 32)
    else
      lowcase := ch;
  end;

end.