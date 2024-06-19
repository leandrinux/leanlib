unit
  lbuilder;

interface

  uses
    consts, utils, types, locale, math, uclasses,
    uobject, uexc, ustream, ufstream, ustdout;

  type
    PBuilder = ^TBuilder;
    TBuilder = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      procedure setSourceStream(stream: PStream);
      procedure setSourceFileStream(filename: string);
      procedure setMessageStream(stream: PStream);
      procedure setStandardMessageOutput;
      procedure build;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _source: PStream;
      _message: PStream;
      procedure log(const msg: string);
      procedure logln(const msg: string);
    end;

  const
    C_CLASS_ID_BUILDER = $F00F;

implementation

  { TBuilder public }

  constructor TBuilder.init;
  begin
    inherited init;
    _source := nil;
    _message := nil;
  end;

  destructor TBuilder.done;
  begin
    if _source<>nil then _source^.release;
    if _message<>nil then _message^.release;
    inherited done;
  end;

  function TBuilder.getClassName: string;
  begin
    getClassName := 'TBuilder';
  end;

  function TBuilder.getClassId: word;
  begin
    getClassId := C_CLASS_ID_BUILDER;
  end;

  procedure TBuilder.build;
  begin
    log('[-] Building');
  end;

  procedure TBuilder.setSourceStream(stream: PStream);
  begin
    if _source<>nil then _source^.release;
    _source := stream;
    _source^.retain;
  end;

  procedure TBuilder.setSourceFileStream(filename: string);
  var
    stream: PFileStream;
  begin
    stream := new(PFileStream, initWithPath(filename, EFileReadOnly));
    setSourceStream(stream);
  end;

  procedure TBuilder.setMessageStream(stream: PStream);
  begin
    if _message<>nil then _message^.release;
    _message := stream;
    _message^.retain;
  end;

  procedure TBuilder.setStandardMessageOutput;
  var
    stream: PStdOutput;
  begin
    stream := new(PStdOutput, init);
    setMessageStream(stream);
  end;

  { TBuilder private }

  procedure TBuilder.log(const msg: string);
  begin
    if _message<>nil then _message^.write(incptr(@msg, 1), length(msg));
  end;

  procedure TBuilder.logln(const msg: string);
  begin
    if _message<>nil then _message^.writeln(msg);
  end;

  { Other }

end.
