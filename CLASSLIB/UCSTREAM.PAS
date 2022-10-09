{
  ucstream Unit
  a stream that writes and reads data from another stream using XOR encoding
  2022 LRT
}
unit
  ucstream;

interface

  uses
    consts, utils, uexc, uclasses, types, locale, uobject, ustream,
    math;

  type
    PCodedStream = ^TCodedStream;
    TCodedStream = object (TStream)
    public
      constructor initWithPassword(password: string; stream: PStream);
      constructor initWithBufferPassword(buffer: pointer; size: word; stream: PStream);
      destructor done; virtual;
      procedure read(buffer: pointer; count: word; var result: word); virtual;
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

  { TCodedStream public }

  constructor TCodedStream.initWithPassword(password: string; stream: PStream);
  begin
    inherited init;
    _stream := stream;
    _stream^.retain;
    _passlength := length(password);
    GetMem(_password, _passlength);
    Move(incptr(@password, 1)^, _password^, _passlength);
  end;

  constructor TCodedStream.initWithBufferPassword(buffer: pointer; size: word; stream: PStream);
  begin
    inherited init;
    _stream := stream;
    _stream^.retain;
    _passlength := size;
    GetMem(_password, _passlength);
    Move(buffer^, _password^, _passlength);
  end;

  destructor TCodedStream.done;
  begin
    _stream^.release;
    FreeMem(_password, _passlength);
    inherited done;
  end;

  procedure TCodedStream.read(buffer: pointer; count: word; var result: word);
  var
    passoffset: word;
  begin
    passoffset := _stream^.getPosition mod _passlength;
    _stream^.read(buffer, count, result);
    doXOR(buffer, buffer, result, passoffset);
  end;

  procedure TCodedStream.write(buffer: pointer; count: word);
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

  procedure TCodedStream.seek(position: longint);
  begin
    _stream^.seek(position);
  end;

  function TCodedStream.getPosition: longint;
  begin
    getPosition := _stream^.getPosition;
  end;

  function TCodedStream.isReadOnly: boolean;
  begin
    isReadOnly := _stream^.isReadOnly;
  end;

  function TCodedStream.isEOF: boolean;
  begin
    isEOF := _stream^.isEOF;
  end;

  function TCodedStream.getSize: longint;
  begin
    getSize := _stream^.getSize;
  end;

  function TCodedStream.getClassName: string;
  begin
    getClassName := 'TCodedStream';
  end;

  function TCodedStream.getClassId: word;
  begin
    getClassId := C_CLASS_ID_CodedStream;
  end;

  { TCodedStream private }

  procedure TCodedStream.doXOR(input, output: PChar; count: word; passoffset: word);
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