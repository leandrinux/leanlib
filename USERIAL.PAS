{
  USerial Unit
  Provides read-only stream access to a part of another stream
  2022 LRT
}
unit
  USerial;

interface

  uses
    consts, utils, uexc, uclasses, types, locale, uobject, ustream, math,
    int14;

  type
    PSerial = ^TSerial;
    TSerial = object (TStream)
    public
      constructor initWithPort(port: ESerialPort);
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
      _handle: text;
    end;

implementation

  { TSerial public }

  constructor TSerial.initWithPort(port: ESerialPort);
  begin
    inherited init;
    assign(_handle, 'COM' + chr(1+ord(port)+ord('0')));
    rewrite(_handle);
  end;

  destructor TSerial.done;
  begin
    close(_handle);
    inherited done;
  end;

  function TSerial.read(buffer: pointer; count: word): word;
  begin
    iassert(false, @self, 0, S_ERR_UNSUPPORTED_ACTION);
  end;

  procedure TSerial.write(buffer: pointer; count: word);
  var
    p: pchar;
    i: word;
  begin
    p := buffer;
    for i:=1 to count do
    begin
      system.write(_handle, p^);
      inc(p);
    end;
  end;

  procedure TSerial.seek(pos: longint);
  begin
    iassert(false, @self, 0, S_ERR_UNSUPPORTED_ACTION);
  end;

  function TSerial.getPosition: longint;
  begin
    iassert(false, @self, 0, S_ERR_UNSUPPORTED_ACTION);
  end;

  function TSerial.isEOF: boolean;
  begin
    iassert(false, @self, 0, S_ERR_UNSUPPORTED_ACTION);
  end;

  function TSerial.getSize: longint;
  begin
    iassert(false, @self, 0, S_ERR_UNSUPPORTED_ACTION);
  end;

  function TSerial.isReadOnly: boolean;
  begin
    isReadOnly := false;
  end;

  function TSerial.getClassName: string;
  begin
    getClassName := 'TSerial';
  end;

  function TSerial.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Serial;
  end;

  { TSerial private }

  { Other }

end.