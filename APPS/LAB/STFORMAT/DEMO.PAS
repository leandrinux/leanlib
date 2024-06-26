uses 
  STFormat;

var
  s: string;

begin
  s := '';
  s := strformat(
    'Hello %0, how are you? My name is %1, what is yours %0? I am from %2. ' +
    'btw the symbol %% is called a percentage',
    'Leandro' + #0 + 'Conrad' + #0 + 'South Korea'
  );
  writeln(s);
end.