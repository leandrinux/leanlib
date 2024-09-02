{
  Datetime Unit
  Used to show debug information
  2022 LRT
}
unit
  debug;

{$IFDEF DEBUG}

interface

  procedure dbg_writehex(ptr: pointer; length: word);

implementation

  uses
    utils;

  procedure dbg_writehex(ptr: pointer; length: word);
  var
    i: word;
    p: ^byte;
  begin
    p := ptr;
    for i:= 0 to length - 1 do
    begin
      write(byteToHex(p^));
      if (i and $000F) = 0 then writeln else write(' ');
      inc(p);
    end;
    writeln;
  end;

begin
  writeln('Using debug unit');

{$ELSE}

interface
implementation

{$ENDIF}
end.
