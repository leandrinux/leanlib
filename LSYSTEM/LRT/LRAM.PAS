{
  lsystem RAM unit
}
unit
  lram;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ustream,
    lcommon, lrbase, ldevice, ltexts;

  const
    C_CLASS_ID_RAM = 5002;

  type
    PRAM = ^TRAM;
    TRAM = object (TDevice)
    public
      constructor initWithSize(size: TUInt32);
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure load(stream: PStream; position: TUInt32);
      function command(cmd: byte; value: TUInt32): boolean; virtual;
      function read(buffer: pchar; count: word): word; virtual;
      function write(buffer: pchar; count: word): word; virtual;
    private
      _data: pchar;
      _size: word;
      _index: TUInt32;
    end;

implementation

  { TRAM public }

  constructor TRAM.initWithSize(size: TUInt32);
  begin
    inherited init;
    getMem(_data, size);
    _size := size;
    _index := 0;
  end;

  destructor TRAM.done;
  begin
    freeMem(_data, _size);
    inherited done;
  end;

  function TRAM.getClassName: string;
  begin
    getClassName := 'TRAM';
  end;

  function TRAM.getClassId: word;
  begin
    getClassId := C_CLASS_ID_RAM;
  end;

  procedure TRAM.load(stream: PStream; position: TUInt32);
  var
    p: pchar;
    size: TUInt32;
  begin
    p := _data;
    inc(p, position);
    size := stream^.getSize - stream^.getPosition;
    if size>_size then msg(EMsgFatal, C_STR_BINARY_TOO_BIG, '');
    stream^.read(p, size);
  end;

  function TRAM.command(cmd: byte; value: TUInt32): boolean;
  begin
    command := false;
    if cmd = C_RAM_CMD_SEEK then
    begin
      _index := value;
      command := true;
    end;
  end;

  function TRAM.read(buffer: pchar; count: word): word;
  var
    p: pchar;
    i, c: word;
  begin
    p := _data;
    inc(p, _index);
    c := count;
    while (c>0) and (_index<_size) do
    begin
      buffer^ := p^;
      dec(c);
      inc(_index);
      inc(p);
    end;
    read := count - c;
  end;

  function TRAM.write(buffer: pchar; count: word): word;
  begin
    write := 0;
  end;

  { TRAM private }

  { Other }

end.
