{$M 2048,0,0}

uses    
  dos;

var 
  h1,m1,s1,cs1: word;
  h2,m2,s2,cs2: word;
  path, cmdline: string;
  i: byte;
  total1, total2: longint;

begin
  if paramcount=0 then
  begin
    writeln('specify a command to measure');
    halt(1);
  end;
  getTime(h1,m1,s1,cs1);
  path := paramstr(1);
  i:=2;
  cmdline:='';
  while paramstr(i)<>'' do cmdline:=cmdline + ' ' +paramstr(i);
  writeln('timing ',path, ' ', cmdline);
  exec(path, cmdline);
  getTime(h2,m2,s2,cs2);
  total1 := longint(cs1) + longint(s1)*100 + longint(m1)*600 + longint(h1)*360000;
  total2 := longint(cs2) + longint(s2)*100 + longint(m2)*600 + longint(h2)*360000;
  writeln('total time: ', total2-total1, 'cs');
end.