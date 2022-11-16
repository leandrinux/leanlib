uses
  xcrt, ufstream, ujson, ulist, udict, utils;

var
  fs: PFileStream;
  js: PJsonReader;
  d: PDictionary;
  l: PList;

begin
  fs := new(PFileStream, initWithPath('res\example.jsn', EFileReadOnly));
  js := new(PJsonReader, init);
  d := PDictionary(js^.open(fs));
  writeln('Name: ', d^.getString('name'));
  writeln('Age: ', d^.getLong('age'));
  writeln('Is Alive: ', booltostr(d^.getBool('isAlive')));
  writeln('Is Evil: ', booltostr(d^.getBool('isEvil')));
  l := PList(d^.getObject('victims'));
  writeln('Victim Count: ', inttostr(l^.getCount));
  writeln('Victim names:');
  l^.moveToStart;
  while l^.getObjectAtCursor <> nil do
  begin
    writeln('  * ', l^.getStringAtCursor);
    l^.moveForward;
  end;
  js^.release;
  fs^.release;
  readkey;
end.