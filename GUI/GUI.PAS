uses
  uobject, umstream, ufstream, ujson;

var
  reader: PJsonReader;
  fs: PFileStream;
  ms: PMemoryStream;
  obj: PObject;

begin
  writeln('Copying file to memory');
  fs := new(PFileStream, initWithPath('\leanlib\gui\res\demo.gui', true));
  ms := new(PMemoryStream, initWithSize(fs^.getSize));
  fs^.copyAllTo(ms);
  ms^.seek(0);
  fs^.release;
  
  writeln('Parsing JSON file');
  reader := new(PJsonReader, init);
  obj := reader^.open(ms);
  ms^.release;
  reader^.release;

  writeln('Parsing complete. Root object class is ', obj^.getClassName);
end.