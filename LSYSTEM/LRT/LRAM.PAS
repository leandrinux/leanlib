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
      procedure loadStream(stream: PStream; position: TUInt32);
      function readMemory(buffer: pchar; position: TUInt32; count: word): word;
    private
      _data: pchar;
      _dataSize: word;
    end;

implementation

  { TRAM public }

  constructor TRAM.initWithSize(size: TUInt32);
  begin
    inherited init;
    _dataSize := size;
    getMem(_data, _dataSize);
  end;

  destructor TRAM.done;
  begin
    freeMem(_data, _dataSize);
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

  procedure TRAM.loadStream(stream: PStream; position: TUInt32);
  var
    p: pchar;
    size: TUInt32;
  begin
    p := _data;
    inc(p, position);
    size := stream^.getSize - stream^.getPosition;
    if size > _dataSize then msg(EMsgFatal, C_STR_BINARY_TOO_BIG, '');
    stream^.read(p, size);
  end;

  function TRAM.readMemory(buffer: pchar; position: TUInt32; count: word): word;
  var
    p: pchar;
    c: word;
  begin
    p := _data;
    inc(p, position);
    c := count;
    while (c>0) and (position<_dataSize) do
    begin
      buffer^ := p^;
      dec(c);
      inc(position);
      inc(p);
    end;
    readMemory := count - c;
  end;

  { TRAM private }

  { Other }

end.
