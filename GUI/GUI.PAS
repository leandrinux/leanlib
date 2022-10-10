uses
  ujson;

var
  reader: PJsonReader;

begin
  reader := new(PJsonReader, init);

  reader^.release;
end.