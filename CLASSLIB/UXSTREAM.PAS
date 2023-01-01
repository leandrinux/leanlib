{
  uxstream Unit
  a stream that writes and reads data from another stream using XOR encoding
  2022 LRT
}
unit
  uxstream;

interface

  uses
    consts, utils, uexc, uclasses, types, locale, uobject, ustream,
    math;

  type
    PXorStream = ^TXorStream;
    TXorStream = object (TStream)
    public
      constructor initWithPassword(password: string; stream: PStream);
      constructor initWithBufferPassword(buffer: pointer; size: word; stream: PStream);
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
      _password: pointer;
      _passlength: word;
      procedure doXOR(input, output: PChar; count: word; passoffset: word);
    end;

implementation

  { TXorStream public }

  constructor TXorStream.initWithPassword(password: string; stream: PStream);
  begin
    inherited init;
    _stream := stream;
    _stream^.retain;
    _passlength := length(password);
    GetMem(_password, _passlength);
    Move(incptr(@password, 1)^, _password^, _passlength);
  end;

  constructor TXorStream.initWithBufferPassword(buffer: pointer; size: word; stream: PStream);
  begin
    inherited init;
    _stream := stream;
    _stream^.retain;
    _passlength := size;
    GetMem(_password, _passlength);
    Move(buffer^, _password^, _passlength);
  end;

  destructor TXorStream.done;
  begin
    _stream^.release;
    FreeMem(_password, _passlength);
    inherited done;
  end;

  function TXorStream.read(buffer: pointer; count: word): word;
  var
    passoffset: word;
    result: word;
  begin
    passoffset := _stream^.getPosition mod _passlength;
    result := _stream^.read(buffer, count);
    doXOR(buffer, buffer, result, passoffset);
    read := result;
  end;

  procedure TXorStream.write(buffer: pointer; count: word);
  var
    encoded: pointer;
    passoffset: word;
  begin
    passoffset := _stream^.getPosition mod _passlength;
    GetMem(encoded, count);
    doXOR(buffer, encoded, count, passoffset);
    _stream^.write(encoded, count);
    FreeMem(encoded, count);
  end;

  procedure TXorStream.seek(position: longint);
  begin
    _stream^.seek(position);
  end;

  function TXorStream.getPosition: longint;
  begin
    getPosition := _stream^.getPosition;
  end;

  function TXorStream.isReadOnly: boolean;
  begin
    isReadOnly := _stream^.isReadOnly;
  end;

  function TXorStream.isEOF: boolean;
  begin
    isEOF := _stream^.isEOF;
  end;

  function TXorStream.getSize: longint;
  begin
    getSize := _stream^.getSize;
  end;

  function TXorStream.getClassName: string;
  begin
    getClassName := 'TXorStream';
  end;

  function TXorStream.getClassId: word;
  begin
    getClassId := C_CLASS_ID_XorStream;
  end;

  { TXorStream private }

  procedure TXorStream.doXOR(input, output: PChar; count: word; passoffset: word);
  var
    i: word;
    p: PChar;
  begin
    passoffset := _stream^.getPosition mod _passlength;
    p := _password;
    for i := count - 1 downto 0 do
    begin
      output^ := char(byte(input^) xor byte(p^));
      inc(p);
      if Ofs(p^) - Ofs(_password^) = count then p := _password;
      inc(input);
      inc(output);
    end;
  end;

  { Other }

end.