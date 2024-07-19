{$M 2048,0,0}

uses    
  dos;

var 
  h1,m1,s1,cs1: word;
  h2,m2,s2,cs2: word;
  path, cmdline: string;
  i: byte;
  result: longint;

begin
  if paramcount=0 then
  begin
    writeln('specify a command to measure');
    halt(1);
  end;
  path := paramstr(1);
  cmdline:= paramstr(2);
  for i:= 3 to paramcount do cmdline:= cmdline + ' ' + paramstr(i);
  writeln('timing "', path, '" with args "', cmdline, '"');
  getTime(h1,m1,s1,cs1);
  exec(path, cmdline);
  getTime(h2,m2,s2,cs2);
  writeln(h1, ':', m1, ':', s1, '.', cs1);
  writeln(h2, ':', m2, ':', s2, '.', cs2);
  result := (cs2-cs1) + (s2-s1)*100 + (m2-m1)*600 + (h2-h1)*360000;
  writeln('total time: ', result, 'cs');
end.