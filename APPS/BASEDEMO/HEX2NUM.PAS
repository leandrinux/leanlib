uses
  xcrt, utils;
  
procedure testValue(v: longint);
begin
  writeln(v:8, ' ', longtohex(v), ' ', hextolong(longtohex(v)));
end;

begin
  testValue(0);
  testValue($A);
  testValue($A0);
  testValue($323);
  testValue($A0E1);
  testValue($FAFA);
  testValue($CAFE);
  testValue($BABECAFE);
  readkey;
end.