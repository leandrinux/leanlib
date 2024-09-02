{
  ucstream Unit

  2022 LRT
}
unit
  ucstream;

interface

  uses
    consts, utils, uclasses, types, locale, math,
    uobject, uexc, ustream;

  type
    PCachedStream = ^TCachedStream;
    TCachedStream = object (TStream)
    public
      constructor initWithStream(stream: PStream; cacheSize: word);
      destructor done; virtual;
      function read(buffer: pointer; count: word): word; virtual;
      procedure write(buffer: pointer; count: word); virtual;
      procedure seek(position: longint); virtual;
      function getPosition: longint; virtual;
      function isEOF: boolean; virtual;
      function getSize: longint; virtual;
      function isReadOnly: boolean; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _stream: PStream;
      _sourceSize: longint;
      _cache: PByte;
      _cacheSize: word;
      _from: longint;
      _count: word;
      _relativePos: longint;
    end;

implementation

  { TCachedStream public }

  constructor TCachedStream.initWithStream(stream: PStream; cacheSize: word);
  begin
    inherited init;
    _stream := stream;
    _stream^.retain;
    _sourceSize := _stream^.getSize;
    _cacheSize := cacheSize;
    getMem(_cache, _cacheSize);
    _count := 0;
    seek(0);
  end;

  destructor TCachedStream.done;
  begin
    freeMem(_cache, _cacheSize);
    _stream^.release;
    inherited done;
  end;

  function TCachedStream.read(buffer: pointer; count: word): word;
  var 
    remaining: word;
    src, dst: pbyte;
    chunkSize: word;
  begin
    remaining := count;
    dst := buffer;
    while not isEOF and (remaining > 0) do
    begin
      if _relativePos = _cacheSize then seek(_from + _cacheSize);
      src := _cache;
      inc(src, _relativePos);
      chunkSize := minword(remaining, _count - _relativePos);
      Move(src^, dst^, chunkSize);
      inc(dst, chunkSize);
      dec(remaining, chunkSize);
      inc(_relativePos, chunkSize);
    end;
    read := count - remaining;
  end;

  procedure TCachedStream.write(buffer: pointer; count: word); 
  begin
    iassert(false, @self, 0, S_ERR_UNSUPPORTED_ACTION);
  end;

  procedure TCachedStream.seek(position: longint);
  begin
    if (position >= _from) and (position <= (_from + _count - 1)) then
    begin
      _relativePos := position - _from;
    end else
    begin
      _stream^.seek(position);
      _count := _stream^.read(_cache, _cacheSize);
      _from := position;
      _relativePos := 0;
    end; 
  end; 

  function TCachedStream.getPosition: longint; 
  begin
    getPosition := _from + _relativePos;
  end;

  function TCachedStream.isEOF: boolean; 
  begin
    isEOF := (_from + _relativePos) = _sourceSize;
  end;

  function TCachedStream.getSize: longint; 
  begin
    getSize := _sourceSize;
  end;

  function TCachedStream.isReadOnly: boolean; 
  begin
    isReadOnly := true;
  end;
    
  function TCachedStream.getClassName: string;
  begin
    getClassName := 'TCachedStream';
  end;

  function TCachedStream.getClassId: word;
  begin
    getClassId := C_CLASS_ID_CachedStream;
  end;

  { TCachedStream private }

  { Other }

end.
