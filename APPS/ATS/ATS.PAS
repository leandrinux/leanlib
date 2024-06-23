{ ATS - Automatic Time Stamp }

{ this program generates code for a unit that contains two }
{ constants with the current date and time. Before building }
{ a program, you run this generator to create the code of the }
{ unit, then you build your program and, in this way, you }
{ can get the build date and time automatized into your app }
uses
  dos;
var 
  h, min, s, ms: word;
  y, m, d, dw: word;
begin
  getTime(h,min,s,ms);
  getDate(y,m,d,dw);
  writeln('unit ats;');
  writeln('interface');
  writeln('const');
  write('  C_BUILD_TIME = ''');
  write(h, ':', min, ':', s, '.', ms);
  writeln(''';');
  write('  C_BUILD_DATE = ''');
  write(y, '/', m, '/', d);
  writeln(''';');
  writeln('implementation');
  writeln('end.');
end.