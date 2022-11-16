uses
  xcrt, types, test,
  uobject, ustream, ufstream, ujson;

const
  C_FILE_PATH = 'RES\EXAMPLE.JSN';

var
  fs: PFileStream;

function testJSONRead(p: pointer): boolean; far;
var
  jr: PJsonReader;
  stream: PStream;
begin
  stream := PStream(p);
  jr := new(PJsonReader, init);
  stream^.seek(0);
  jr^.open(stream);
  jr^.release;
end;

begin
  fs := new(PFileStream, initWithPath(C_FILE_PATH, EFileReadOnly));
  measure('testJSONRead', testJSONRead, fs, 10);
  readkey;
  fs^.release;
end.