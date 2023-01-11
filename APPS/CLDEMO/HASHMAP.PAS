uses
  xcrt, uhashmap, ustring, unumber, utils;

var
  hashmap: PHashmap;
  m: longint;

begin
  m := memAvail;
  writeln('MemAvail before creation: ', m);
  hashmap := new(PHashmap, init);
  writeln('MemAvail diff after creation: ', m - memAvail);

  hashmap^.add(15, new(PString, initWithValue('Hello World!'))^.autorelease);
  hashmap^.add($FAFA, new(PNumber, initWithValue(42))^.autorelease);
  hashmap^.add($DEADCAFE, new(PString, initWithValue('This is another test'))^.autorelease);

  writeln('Hashmap size:', hashmap^.getSize);
  writeln('Hashmap count:', hashmap^.getCount);
  writeln('MemAvail diff after adding objects: ', m - memAvail);

  writeln('First value: ', hashmap^.get(15)^.getHumanReadableString);
  writeln('Second value: ', hashmap^.get($FAFA)^.getHumanReadableString);
  writeln('Third value: ', hashmap^.get($DEADCAFE)^.getHumanReadableString);

  writeln('Is nil when not found?: ', booltostr(hashmap^.get(64) = nil));

  hashmap^.release;
  writeln('MemAvail diff after release: ', m - memAvail);

  readkey;

end.