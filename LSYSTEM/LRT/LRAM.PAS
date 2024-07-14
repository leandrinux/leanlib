{
  lsystem RAM unit
}
unit
  lram;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ustream,
    lcommon, lregs, ldevice, ltexts;

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
      procedure loadStream(source: PStream; bytesToLoad: word; memoryPosition: TUInt32);
      function readFromMemory(buffer: pchar; memoryPosition: TUInt32; bytesToRead: word): word;
      procedure setValue(address: TUInt32; value: TUInt32);
      function getValue(address: TUInt32): TUInt32;
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

  procedure TRAM.loadStream(source: PStream; bytesToLoad: word; memoryPosition: TUInt32);
  var
    p: pchar;
  begin
    if bytesToLoad > _dataSize then msg(EMsgFatal, C_STR_BINARY_TOO_BIG, '');
    p := _data;
    inc(p, memoryPosition);
    source^.read(p, bytesToLoad)
  end;

  function TRAM.readFromMemory(buffer: pchar; memoryPosition: TUInt32; bytesToRead: word): word;
  var
    p: pchar;
    bytesRead: word;
  begin
    p := _data;
    inc(p, memoryPosition);
    bytesRead := 0;
    while (bytesRead<bytesToRead) and (memoryPosition<_dataSize) do
    begin
      buffer^ := p^;
      inc(bytesRead);
      inc(p);
      inc(buffer);
      inc(memoryPosition);
    end;
    readFromMemory := bytesRead;
  end;

  procedure TRAM.setValue(address: TUInt32; value: TUInt32);
  var
    p: pchar;
  begin
    p := _data;
    inc(p, address);
    PUInt32(p)^ := value;
  end;

  function TRAM.getValue(address: TUInt32): TUInt32;
  var
    p: pchar;
  begin
    p := _data;
    inc(p, address);
    getValue := PUInt32(p)^;    
  end;

  { TRAM private }

  { Other }

end.
