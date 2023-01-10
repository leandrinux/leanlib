uses
  xcrt, types, ustream, ufstream, ucstream;

const
  C_FILE_PATH = 'RES\LOREM.TXT';
  C_BUFFER_SIZE = 100;

procedure dump(stream: PStream);
var
  buffer, p: pbyte;
  res: word;
begin
  getMem(buffer, C_BUFFER_SIZE);
  while not stream^.isEOF do
  begin
    stream^.read(buffer, C_BUFFER_SIZE, res);
    p := buffer;
    while res>0 do
    begin
      write(char(p^));
      inc(p);
      dec(res);
    end;
  end;
  freeMem(buffer, C_BUFFER_SIZE);
end;

var
  fs: PFileStream;
  cs: PCachedStream;

begin
  fs := new(PFileStream, initWithPath(C_FILE_PATH, EFileReadOnly));
  cs := new(PCachedStream, initWithStream(fs, 4096));
  dump(cs);
  cs^.release;
  fs^.release;
  readkey; 
end.