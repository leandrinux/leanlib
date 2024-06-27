uses
  morestrs;

begin
  {$IFDEF Spanish}
  writeln('Hola mundo! Chau mundo!');
  {$ELSE}
  writeln(C_STR_GREET);
  {$ENDIF}
end.