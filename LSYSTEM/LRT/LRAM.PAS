{
  lsystem RAM unit
}
unit
  lram;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ustream,
    lcommon, ldevice, ltexts;

  const
    C_CLASS_ID_RAM = 5002;
    C_DEVICE_TYPE = $0A;
    C_CMD_GET_MEMORY_SIZE  = $01;

  type
    PRAM = ^TRAM;
    TRAM = object (TDevice)
    public
      constructor initWithSize(size: TUInt32);
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      function readByte(var value: byte): boolean; virtual;
      function writeByte(value: byte): boolean; virtual;
      procedure loadStream(source: PStream; bytesToLoad: word; memoryPosition: TUInt32);
      function readFromMemory(buffer: pchar; memoryPosition: TUInt32; bytesToRead: word): word;
      procedure setValue(address: TUInt32; value: TUInt32);
      function getValue(address: TUInt32): TUInt32;
      function getName: TDeviceName; virtual;
    private
      _data: pchar;
      _dataSize: TUInt32;

      _responseBuffer: array[0..3] of byte;
      _bufferPosition: byte;
      _bufferSize: byte;
    end;

implementation

  { TRAM public }

  constructor TRAM.initWithSize(size: TUInt32);
  begin
    inherited init;
    _dataSize := size;
    getMem(_data, _dataSize);
    fillchar(_responseBuffer, sizeof(_responseBuffer), 0);
    _bufferPosition := 0;
    _bufferSize := 0;
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

  function TRAM.readByte(var value: byte): boolean;
  begin
    if _bufferPosition < _bufferSize then
    begin
      value := _responseBuffer[_bufferPosition];
      inc(_bufferPosition);
      readByte := true;
    end else
      readByte := false;
  end;

  function TRAM.writeByte(value: byte): boolean;
  begin
    writeByte := false;
    case value of
      C_CMD_GET_DEVICE_TYPE:
      begin
        _responseBuffer[0] := C_DEVICE_TYPE;
        _bufferPosition := 0;
        _bufferSize := 1;
        writeByte := true;
      end;

      C_CMD_GET_MEMORY_SIZE:
      begin
        _responseBuffer[0] := _dataSize and $FF;
        _responseBuffer[1] := (_dataSize shr 8) and $FF;
        _responseBuffer[2] := (_dataSize shr 16) and $FF;
        _responseBuffer[3] := (_dataSize shr 24) and $FF;
        _bufferPosition := 0;
        _bufferSize := 4;
        writeByte := true;
      end;
    end;
  end;

  function TRAM.getName: TDeviceName;
  begin
    getName := 'Virtual RAM Device';
  end;

  { TRAM private }

  { Other }

end.
