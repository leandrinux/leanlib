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
      _line: string;
      _nestedCommentBlocks: byte;
      procedure log(const msg: string);
      procedure logln(const msg: string);
      procedure cleanComments;
      procedure processLine;
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
    logln('[-] Building');
    _nestedCommentBlocks := 0;
    while not _source^.isEOF do processLine;
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

  procedure TBuilder.cleanComments;
  var
    isDone: boolean;
    i: byte;
  begin
    i := 0;
    isDone := false;
    while (not isDone) and (not _source^.isEOF) and (i<=length(_line)) do
    begin
      if (_line[i]='/') then
      begin
        if (i<length(_line)) then
        begin
          if (_line[i+1] = '/') then
          begin
            { found a comment until EoL }
            { we clean the line and return }
            _line := copy(_line, 1, i-1);
            isDone := true;
          end else if (_line[i+1] = '*') then
          begin
            { we found a comment block start }
            inc(_nestedCommentBlocks);
            _line := copy(_line, 1, i-1);
            isDone := true;
          end;
        end;
      end else 
        if (_line[i]='*') and (i<length(_line)) and (_line[i+1] = '/') then
        begin
          { we found a comment block end }
          _line := copy(_line, i+2, length(_line)-i-2);
          dec(_nestedCommentBlocks);
          i := 0;
          isDone := true;
        end;
      inc(i);
    end;
    if (_nestedCommentBlocks>0) then
    begin
      if (i>length(_line)) then 
        _line := '';
    end;
  end;

  procedure TBuilder.processLine;
  begin
    _line := _source^.readln;
    cleanComments;
    if length(_line)>0 then writeln(_line);
  end;

  { Other }

end.
