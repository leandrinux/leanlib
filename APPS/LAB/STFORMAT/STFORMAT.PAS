unit
  STFormat;

interface

  function strformat(const str, args: string): string;

implementation

  function strformat(const str, args: string): string;

    function getArg(const args: string; index: byte): string;
    var
      i, j: byte;
      result: string;
    begin
      i := 1;
      j := 0;
      result := '';
      while (i <= length(args)) and (j <> index) do
      begin
        if args[i] = #0 then inc(j);
        inc(i);
      end;
      if j = index then
        while (i <= length(args)) and (args[i]<>#0) do
        begin
          result := result + args[i];
          inc(i);
        end;
      getArg := result;
    end;

  var 
    result: string;
    i: byte;
    ch: char;
  begin
    result := '';
    i := 1;
    while i <= length(str) do
    begin
      ch := str[i];
      if (str[i] = '%') then
        if (i+1<=length(str)) then
        begin
          if (str[i+1] in ['0'..'9']) then 
          begin
            ch := #0;
            result := result + getArg(args, ord(str[i+1]) - ord('0'));
            inc(i);
          end else if str[i+1]='%' then 
            inc(i);
        end;
      if ch <> #0 then result := result + ch;
      inc(i);
    end;


    strformat := result;
  end;
  
end.