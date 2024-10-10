uses
  strings;

begin
  writeln('co starts with cow?: ', startsWith('co', 'cow'));
  writeln('cowabunga starts with cow?: ', startsWith('cowabunga', 'cow'));
  writeln('cowabunga starts with cowabunga?: ', startsWith('cowabunga', 'cowabunga'));
  writeln('cowabunga starts with cowabungalicious?: ', startsWith('cowabunga', 'cowabungalicious'));

  writeln('cow contains an a?: ', contains('cow', ['a']));
  writeln('cow contains an a or a w?: ', contains('cow', ['a', 'w']));
  writeln('cow contains a c?: ', contains('cow', ['c']));
end.