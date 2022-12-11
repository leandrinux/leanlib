uses
  xcrt, ufstream, ujson, ulist, udict, utils, types;

var
  fs: PFileStream;
  js: PJsonReader;
  d: PDictionary;
  l: PList;

begin
  fs := new(PFileStream, initWithPath('res\example.jsn', EFileReadOnly));
  js := new(PJsonReader, init);
  d := PDictionary(js^.open(fs));
  writeln('Name: ', d^.getString('name', ''));
  writeln('Age: ', d^.getLong('age', 0));
  writeln('Is Alive: ', booltostr(d^.getBool('isAlive', false)));
  writeln('Is Evil: ', booltostr(d^.getBool('isEvil', false)));
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