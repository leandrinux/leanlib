{
  ustdout Unit
  Provides read-only stream access to a part of another stream
  2022 LRT
}
unit
  ustdout;

interface

  uses
    consts, utils, uexc, uclasses, types, locale, uobject, ustream, math;

  type
    PStdOutput = ^TStdOutput;
    TStdOutput = object (TStream)
    public
      constructor init;
      destructor done; virtual;
      procedure read(buffer: pointer; count: word; var result: word); virtual;
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

  { TStdOutput public }

  constructor TStdOutput.init;
  begin
    inherited init;
  end;

  destructor TStdOutput.done;
  begin
    _stream^.release;
    inherited done;
  end;

  procedure TStdOutput.read(buffer: pointer; count: word; var result: word);
  begin
    iassert(false, @self, 0, S_ERR_OPERATION_UNSUPPORTED);
  end;

  procedure TStdOutput.write(buffer: pointer; count: word);
  var
    p: pchar;
    i: word;
  begin
    p := buffer;
    for i:=1 to count do
    begin
      system.write(p^);
      inc(p);
    end;
  end;

  procedure TStdOutput.seek(pos: longint);
  begin
    iassert(false, @self, 0, S_ERR_OPERATION_UNSUPPORTED);
  end;

  function TStdOutput.getPosition: longint;
  begin
    iassert(false, @self, 0, S_ERR_OPERATION_UNSUPPORTED);
  end;

  function TStdOutput.isEOF: boolean;
  begin
    iassert(false, @self, 0, S_ERR_OPERATION_UNSUPPORTED);
  end;

  function TStdOutput.getSize: longint;
  begin
    iassert(false, @self, 0, S_ERR_OPERATION_UNSUPPORTED);
  end;

  function TStdOutput.isReadOnly: boolean;
  begin
    isReadOnly := false;
  end;

  function TStdOutput.getClassName: string;
  begin
    getClassName := 'TStdOutput';
  end;

  function TStdOutput.getClassId: word;
  begin
    getClassId := C_CLASS_ID_StdOutput;
  end;

  { TStdOutput private }

  { Other }

end.