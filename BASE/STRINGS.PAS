{
  Strings Unit
  Pascal and null-terminated string manipulation
  2022 LRT
}
unit
  strings;

interface

  uses
    types;

  { returns the word value as a string, left padded with the specified char }
  function padw(w: word; ch: char; count: byte): string5;

  { returns the uppercase version of the provided string }
  function strUpper(s: string): string;

  { returns the lowercase version of the provided string }
  function strLower(s: string): string;

  { returns a substring of the provided string }
  function subString(s: string; position, count:byte): string;

  { converts a null-terminated string to a Pascal-style string }
  function pCharToStr(p: PChar): string;

  { returns the length of a null-terminated string }
  function strlen(p: PChar): word;

  {
    returns a string based on the specified format
    each element in the format string must be tagged as [x] where x is
    a number between 0 and 9. args must be a pointer to an array of pascal
    strings. Each string must be a full pascal string, not a shortened one
    like string[10].
  }
  function strformat(format: string; args: pstr): string;

implementation

  function padw(w: word; ch: char; count: byte): string5;
  var
    s: string5;
  begin
    str(w, s);
    while length(s)<count do s := ch + s;
    padw := s;
  end;

  function strUpper(s: string): string;
  var
    i, len: byte;
    ch: char;
    res: string;
  begin
    res[0] := s[0];
    len := length(s);
    for i := 1 to len do
    begin
      ch := s[i];
      if (ch >= 'a') and (ch <= 'z') then ch := chr(ord(ch) - 32);
      res[i] := ch;
    end;
    strUpper := res;
  end;

  function strLower(s: string): string;
  var
    i, len: byte;
    ch: char;
    res: string;
  begin
    res[0] := s[0];
    len := length(s);
    for i := 1 to len do
    begin
      ch := s[i];
      if (ch >= 'A') and (ch <= 'Z') then ch := chr(ord(ch) + 32);
      res[i] := ch;
    end;
    strLower := res;
  end;

  function subString(s: string; position, count:byte): string;
  var
    res: string;
    i, c: byte;
  begin
    i := position;
    c := position + count;
    res := '';
    while (i<=byte(s[0])) and (i<c) do
    begin
      res := res + s[i];
      inc(i);
    end;
    subString := res;
  end;

  function extractFileName(path: string; includeExtension: boolean): string;
  var
    i: byte;
    s: string;
  begin
    i := length(path);
    if not includeExtension then dec(i, 4);
    s := '';
    while path[i] <> '\' do
    begin
      s := path[i] + s;
      dec(i);
    end;
    extractFileName := s;
  end;

  function pCharToStr(p: PChar): string;
  var s: string;
  begin
    s[0] := #0;
    while (s[0] <> #$FF) and (p^ <> #0) do
    begin
      inc(s[0]);
      s[ord(s[0])] := p^;
      inc(p);
    end;
    pCharToStr := s;
  end;

  function strlen(p: PChar): word;
  var c: word;
  begin
    c := 0;
    while p^ <> #0 do
    begin
      inc(c);
      inc(p);
    end;
    strlen := c;
  end;

  function strformat(format: string; args: pstr): string;
  var
    str: string;
    strIndex, fsIndex, argIndex: byte;
    current, next: char;
    p: pstr;
  begin
    str := '';
    strIndex := 1;
    fsIndex := 1;
    while fsIndex <= length(format) do
    begin
      current := format[fsIndex];
      if (fsIndex+1) <= length(format) then next := format[fsIndex+1] else next := #0;
      if (current <> '[') then
      begin
        str[strIndex] := current;
        str[0] := chr(strIndex);
        inc(strIndex);
        inc(fsIndex);
      end else
      begin
        if (next = '[') or (next = #0) or not (next in ['0'..'9']) then
        begin
          str[strIndex] := current;
          str[0] := chr(strIndex);
          inc(strIndex);
          if (next = '[') then inc(fsIndex, 2) else inc(fsIndex);
        end else begin
          argIndex := ord(next) - ord('0');
          p := args;
          inc(p, argIndex);
          str := str + p^;
          inc(strIndex, length(p^));
          inc(fsIndex, 3);
        end;
      end;
    end;
    strformat := str;
  end;

end.