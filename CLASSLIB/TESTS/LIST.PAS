uses
  ulist;

var 
  list: PList;
  ch: char;

procedure listAll(list: PList);
begin
  list^.moveToStart;
  while list^.getObjectAtCursor <> nil do
  begin
    write(list^.getStringAtCursor, ' ');
    list^.moveForward;
  end;
  writeln;
end;

begin
  list := new(PList, init);
  
  for ch := 'a' to 'z' do list^.addString(ch);
  listAll(list);

  { search an element and remove three from that position }
  writeln('search for "k"');
  list^.moveToStart;
  while (list^.getObjectAtCursor <> nil) and (list^.getStringAtCursor <> 'k') do list^.moveForward;

  writeln('delete "k"');
  list^.removeObjectAtCursor;

  writeln('cursor points at "', list^.getStringAtCursor, '"');

  writeln('list again to show "k" is missing');
  listAll(list);

  writeln('cursor points at "', list^.getStringAtCursor, '"');

  writeln('search for "y"');
  list^.moveToStart;
  while (list^.getObjectAtCursor <> nil) and (list^.getStringAtCursor <> 'y') do list^.moveForward;

  writeln('delete "y"');
  list^.removeObjectAtCursor;

  writeln('delete "z"');
  list^.removeObjectAtCursor;

  writeln('cursor points at "', list^.getStringAtCursor, '"');

  writeln('list once again');
  listAll(list);


  list^.release;
end.