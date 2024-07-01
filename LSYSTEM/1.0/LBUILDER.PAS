unit
  lbuilder;

interface

  uses
    consts, utils, types, locale, math, uclasses,
    uobject, uexc, ustream, ufstream, ucstream, ustdout,
    lcommon, lcbase, lsrccode, lparser;

  const
    C_CLASS_ID_BUILDER = $F00F;

  type
    TBuilderConfig = record
      isVerbose: boolean;
    end;

    PBuilder = ^TBuilder;
    TBuilder = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      procedure setSourceStream(stream: PStream);
      procedure setSourceFileStream(filename: string);
      procedure setMessageStream(stream: PStream);
      procedure setStandardMessageOutput;
      procedure setConfig(const builderConfig: TBuilderConfig);
      procedure build;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _sourceStream: PStream;  { stream used to read the source code }
      _sourceCode: PSourceCode;    { object containing the full source code to be compiled }
      _message: PStream;           { stream used by the compiler to output progress messages }
      _config: TBuilderConfig;     { other configuration settings }
      procedure printSentence(const sentence: TSentence);
    end;

implementation
 
  { TBuilder public }

  constructor TBuilder.init;
  begin
    inherited init;
    fillChar(_config, sizeof(TBuilderConfig), 0);
    _sourceStream := nil;
    _sourceCode := nil;
    _message := nil;
  end;

  destructor TBuilder.done;
  begin
    if _sourceStream<>nil then _sourceStream^.release;
    if _sourceCode <> nil then _sourceCode^.release;
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
  var
    sentence: TSentence;
    count: word;
    parser: PParser;
  begin
    _message^.writeln('[-] Building');
    if _sourceCode <> nil then _sourceCode^.release;
    _sourceCode := new(PSourceCode, initWithStream(_sourceStream));
    if not _sourceCode^.isValid then 
    begin
      writeln('Could not read source code');
      halt(1);
    end;
    parser := new(PParser, initWithSourceCode(_sourceCode));
    count := 0;
    while not _sourceCode^.isReadComplete do
    begin
      parser^.readSentence(sentence);
      parser^.validateSentence(sentence);
      if _config.isVerbose then printSentence(sentence);
      inc(count);
    end;
    parser^.release;
    writeln('[-] ', count, ' sentences processed.')
  end;

  procedure TBuilder.setSourceStream(stream: PStream);
  begin
    if _sourceStream<>nil then _sourceStream^.release;
    _sourceStream := stream;
    _sourceStream^.retain;
  end;

  procedure TBuilder.setSourceFileStream(filename: string);
  var
    fileStream: PFileStream;
  begin
    fileStream := new(PFileStream, initWithPath(filename, EFileReadOnly));
    setSourceStream(fileStream);
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

  procedure TBuilder.setConfig(const builderConfig: TBuilderConfig);
  begin
    _config := builderConfig;
  end;

  { TBuilder private }

  procedure TBuilder.printSentence(const sentence: TSentence);
  const 
    C_PARAM_TYPES : array[EParameterType] of string[10] = (
      'unknown', 'literal', 'register', 'address', 'pointer', 'symbol'
    );
  begin
    with sentence do 
    begin
      write(opname, ' (', opcode, ')');
      if param0 = '' then
        writeln   
      else 
        write(', ', param0, ' (', C_PARAM_TYPES[paramType0], ')');

      if param1 = '' then
        writeln   
      else 
        writeln(', ', param1, ' (', C_PARAM_TYPES[paramType1], ')');
    end;
  end;

end.
