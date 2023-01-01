{
  usstream Unit
  Provides read-only stream access to a part of another stream
  2022 LRT
}
unit
  usstream;

interface

  uses
    consts, utils, uexc, uclasses, types, locale, uobject, ustream, math;

  type
    PSubstream = ^TSubstream;
    TSubstream = object (TStream)
    public
      constructor initWithStream(stream: PStream; fromPos, size: longint);
      destructor done; virtual;
      function read(buffer: pointer; count: word): word; virtual;
      procedure write(buffer: pointer; count: word); virtual;
      procedure seek(pos: longint); virtual;
      function getPosition: longint; virtual;
      function isEOF: boolean; virtual;
      function getSize: longint; virtual;
      function isReadOnly: boolean; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _stream: PStream;
      _fromPos: longint;
      _size, _position: longint;
    end;

implementation

  { TSubstream public }

  constructor TSubstream.initWithStream(stream: PStream; fromPos, size: longint);
  begin
    inherited init;
    _stream := stream;
    _stream^.retain;
    _fromPos := fromPos;
    _position := 0;
    _size := size;
    iassert((fromPos + size - 1) < stream^.getSize, @self, 0, S_ERR_INVALID_BOUNDS);
  end;

  destructor TSubstream.done;
  begin
    _stream^.release;
    inherited done;
  end;

  function TSubstream.read(buffer: pointer; count: word): word;
  var result: word;
  begin
    _stream^.seek(_fromPos + _position);
    result := _stream^.read(buffer, minword(count, _size - _position));
    inc(_position, result);
    read := result;
  end;

  procedure TSubstream.write(buffer: pointer; count: word);
  begin
    iassert(false, @self, 0, S_ERR_UNSUPPORTED_ACTION);
  end;

  procedure TSubstream.seek(pos: longint);
  begin
    _position := pos;
  end;

  function TSubstream.getPosition: longint;
  begin
    getPosition := _position;
  end;

  function TSubstream.isEOF: boolean;
  begin
    isEOF := _position = _size;
  end;

  function TSubstream.getSize: longint;
  begin
    getSize := _size;
  end;

  function TSubstream.isReadOnly: boolean;
  begin
    isReadOnly := true;
  end;

  function TSubstream.getClassName: string;
  begin
    getClassName := 'TSubstream';
  end;

  function TSubstream.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Substream;
  end;

  { TSubstream private }

  { Other }

end.