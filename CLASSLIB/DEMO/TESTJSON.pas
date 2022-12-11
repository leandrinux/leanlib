uses
  xcrt, types, test,
  uobject, ustream, ufstream, ujson, ucstream;

const
  C_FILE_PATH = 'RES\EXAMPLE.JSN';

var
  fs: PFileStream;

function testJSONReadNoCache(p: pointer): boolean; far;
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

function testJSONReadCached(p: pointer): boolean; far;
var
  stream: PCachedStream;
  jr: PJsonReader;
begin
  stream := new(PCachedStream, initWithStream(PStream(p), 4096));
  jr := new(PJsonReader, init);
  stream^.seek(0);
  jr^.open(stream);
  jr^.release;
  stream^.release;
end;

begin
  fs := new(PFileStream, initWithPath(C_FILE_PATH, EFileReadOnly));
{
  measure('testJSONReadNoCache', testJSONReadNoCache, fs, 4);
  measure('testJSONReadCached', testJSONReadCached, fs, 4);
}
  testJSONReadCached(fs);
  readkey;
  fs^.release;
end.