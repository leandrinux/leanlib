uses
  ulist,
  ustring;

procedure addStrings(list: PList);
begin
  writeln('* Add test strings');
  list^.addString('Hello');
  list^.addString('World!');
  list^.addString('This');
  list^.addString('Is');
  list^.addString('A');
  list^.addString('Test');
  writeln('* Count is ', list^.getCount);
end;

procedure writeStrings(list: PList);
var
  str: PString;
begin
  writeln('* List all using cursor');
  list^.moveToStart;
  str := PString(list^.getObjectAtCursor);
  while str<>nil do
  begin
    writeln(str^.getValue);
    list^.moveForward;
    str := PString(list^.getObjectAtCursor);
  end;
end;

procedure writeAhead(list: PList);
var
  str: PString;
begin
  writeln('* Write second element using getObjectAfterCursor');
  list^.moveToStart;
  str := PString(list^.getObjectAfterCursor);
  writeln(str^.getValue);
end;

var
  list: PList;

begin
  list := new(PList, init);
  addStrings(list);
  writeStrings(list);
  writeAhead(list);
  list^.release;
end.