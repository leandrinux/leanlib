{
  UMStream Unit
  A stream that stores data using conventional memory
  2022 LRT
}
unit
  umstream;

interface

  uses
    uexc, uclasses, types, locale, uobject, ustream, math;

  const
    C_BLOCK_SIZE = 60000;  { maximum size of each memory block }
    C_BLOCK_COUNT = 9;         { maximum number of blocks }

  type
    TMemoryBlocks = array[0 .. C_BLOCK_COUNT - 1] of pointer;

  {
    using the default values of 9 blocks of 60000 bytes each, that
    means TMemoryStream can hold up to 540KB
  }
  const
    C_MAX_POSSIBLE_SIZE = C_BLOCK_COUNT * C_BLOCK_SIZE;

  type
    PMemoryStream = ^TMemoryStream;
    TMemoryStream = object (TStream)
    public
      constructor initWithSize(memorySize: longint);
      constructor initWithBuffer(buffer: pointer; bufferSize: word);
      destructor done; virtual;
      function read(buffer: pointer; count: word): word; virtual;
      procedure write(buffer: pointer; count: word); virtual;
      procedure seek(pos: longint); virtual;
      function getPosition: longint; virtual;
      function isEOF: boolean; virtual;
      function getSize: longint; virtual;
      function getMaximumSize: longint;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _blocks: TMemoryBlocks;
      _memorySize: longint;
      _position: longint;
      _maxPosition: longint;
      _mustFreeMemoryBlocks: boolean;
    end;

implementation

  { TMemoryStream }

  constructor TMemoryStream.initWithSize(memorySize: longint);
  var
    remaining: longint;
    block: byte;
  begin
    inherited init;
    iassert(memorySize <= C_MAX_POSSIBLE_SIZE, @self, 0, S_ERR_NOT_ENOUGH_MEMORY);
    FillChar(_blocks, SizeOf(_blocks), 0);
    _memorySize := memorySize;
    _position := 0;
    _maxPosition := 0;
    block := 0;
    remaining := _memorySize;
    while remaining >= C_BLOCK_SIZE do
    begin
      GetMem(_blocks[block], C_BLOCK_SIZE);
      inc(block);
      dec(remaining, C_BLOCK_SIZE);
    end;
    if remaining > 0 then GetMem(_blocks[block], remaining);
    _mustFreeMemoryBlocks := true;
  end;

  constructor TMemoryStream.initWithBuffer(buffer: pointer; bufferSize: word);
  begin
    inherited init;
    _blocks[0] := buffer;
    _memorySize := bufferSize;
    _position := 0;
    _maxPosition := bufferSize;
    _mustFreeMemoryBlocks := false;
  end;

  destructor TMemoryStream.done;
  var
    remaining: longint;
    block: byte;
  begin
    if _mustFreeMemoryBlocks then
    begin
      block := 0;
      remaining := _memorySize;
      while remaining >= C_BLOCK_SIZE do
      begin
        FreeMem(_blocks[block], C_BLOCK_SIZE);
        inc(block);
        dec(remaining, C_BLOCK_SIZE);
      end;
      if remaining > 0 then FreeMem(_blocks[block], remaining);
    end;
    inherited done;
  end;

  function TMemoryStream.read(buffer: pointer; count: word): word;
  var
    remaining: longint;
    block: byte;
    c, offset: word;
    p: pointer;
  begin
    if isEOF then
    begin
      read := 0;
      exit;
    end;
    if (_memorySize - _position) < count then count := _memorySize - _position;
    read := count;
    block := _position div C_BLOCK_SIZE;
    offset := _position mod C_BLOCK_SIZE;
    c := minword(count, C_BLOCK_SIZE - offset);
    p := incptr(_blocks[block], offset);
    Move(p^, buffer^, c);
    remaining := count - c;
    if remaining > 0 then
    begin
      buffer := incptr(buffer, c);
      Move(_blocks[block+1]^, buffer^, remaining);
    end;
    inc(_position, count);
  end;

  procedure TMemoryStream.write(buffer: pointer; count: word);
  var
    block: byte;
    offset: word;
    c: word;
    remainder: word;
    p: pointer;
  begin
    if not (_memorySize - _position >= count) then exit;
    block := _position div C_BLOCK_SIZE;
    offset := _position mod C_BLOCK_SIZE;
    c := minword(C_BLOCK_SIZE - offset, count);
    p := incptr(_blocks[block], offset);
    Move(buffer^, p^, c);
    if c < count then
    begin
      remainder := count - c;
      p := _blocks[block+1];
      buffer := incptr(buffer, c);
      Move(buffer^, p^, remainder);
    end;
    inc(_position, count);
    _maxPosition := maxlong(_maxPosition, _position);
  end;

  procedure TMemoryStream.seek(pos: longint);
  begin
    iassert(pos < _memorySize, @self, 0, S_ERR_INVALID_BOUNDS);
    _position := pos;
  end;

  function TMemoryStream.getClassName: string;
  begin
    getClassName := 'TMemoryStream';
  end;

  function TMemoryStream.getClassId: word;
  begin
    getClassId := C_CLASS_ID_MemoryStream;
  end;

  function TMemoryStream.getPosition: longint;
  begin
    getPosition := _position;
  end;

  function TMemoryStream.isEOF: boolean;
  begin
    isEOF := _position = _memorySize;
  end;

  function TMemoryStream.getSize: longint;
  begin
    getSize := _maxPosition;
  end;

  function TMemoryStream.getMaximumSize: longint;
  begin
    getMaximumSize := _memorySize;
  end;

  { Other }

end.