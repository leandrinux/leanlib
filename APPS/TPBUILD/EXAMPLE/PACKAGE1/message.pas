unit
  message;

interface

  procedure writeMessage(const str: string);

implementation

  procedure writeMessage(const str: string);
  begin
    write('[*] ');
    writeln(str);
  end;

end.