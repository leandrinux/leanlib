unit
  lbuilder;

interface

  uses
    consts, utils, types, locale, math, uclasses, strings,
    uobject, uexc, ustream, ufstream, ucstream, ustdout,
    lcommon, lcbase, lsrccode, lcparser, ltexts, lbinary;

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
      procedure setTargetStream(stream: PStream);
      procedure setTargetFileStream(filename: string);
      procedure setConfig(const builderConfig: TBuilderConfig);
      procedure build;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _sourceStream: PStream;      { stream used to read the source code }
      _targetStream: PStream;      { stream used to write the binary code }
      _config: TBuilderConfig;     { other configuration settings }
      procedure printSentence(lineCount: word; const sentence: TSentence);
    end;

implementation
 
  { TBuilder public }

  constructor TBuilder.init;
  begin
    inherited init;
    fillChar(_config, sizeof(TBuilderConfig), 0);
    _sourceStream := nil;
    _targetStream := nil;
  end;

  destructor TBuilder.done;
  begin
    if _sourceStream<>nil then _sourceStream^.release;
    if _targetStream<>nil then _targetStream^.release;
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
    sourceCode: PSourceCode;    { contains the full source code to be compiled }
    binary: PBinary;            { contains the full binary code and data }
    parser: PCodeParser;            { reads and validates the source code }
  begin
    if _sourceStream = nil then error(C_STR_SOURCE_NOT_SET);
    if _targetStream = nil then error(C_STR_TARGET_NOT_SET);
    message(C_STR_BUILDING);
    sourceCode := new(PSourceCode, initWithStream(_sourceStream));
    if not sourceCode^.isValid then error(C_STR_READ_ERROR);
    parser := new(PCodeParser, initWithSourceCode(sourceCode));
    binary := new(PBinary, init);
    count := 0;
    while not sourceCode^.isReadComplete do
    begin
      parser^.parseSentence(sentence);
      if _config.isVerbose then printSentence(count, sentence);
      binary^.addSentence(sentence);
      inc(count);
    end;
    message(strformatn(C_STR_SENTENCES_PROC, intToStr(count)));
    binary^.make;
    binary^.save(_targetStream);
    binary^.release;
    parser^.release;
    sourceCode^.release;
  end;

  procedure TBuilder.setSourceStream(stream: PStream);
  begin
    if _sourceStream<>nil then _sourceStream^.release;
    _sourceStream := stream;
    _sourceStream^.retain;
  end;

  procedure TBuilder.setTargetStream(stream: PStream);
  begin
    if _targetStream<>nil then _targetStream^.release;
    _targetStream := stream;
    _targetStream^.retain;
  end;

  procedure TBuilder.setSourceFileStream(filename: string);
  var
    fileStream: PFileStream;
  begin
    fileStream := new(PFileStream, initWithPath(filename, EFileReadOnly));
    setSourceStream(fileStream);
  end;

  procedure TBuilder.setTargetFileStream(filename: string);
  var
    fileStream: PFileStream;
  begin
    fileStream := new(PFileStream, initWithPath(filename, EFileCreate));
    setTargetStream(fileStream);
  end;

  procedure TBuilder.setConfig(const builderConfig: TBuilderConfig);
  begin
    _config := builderConfig;
  end;

  { TBuilder private }

  procedure TBuilder.printSentence(lineCount: word; const sentence: TSentence);
  const 
    C_PARAM_TYPES : array[EParameterType] of string[10] = (
      'unknown', 'literal', 'register', 'address', 'pointer', 'symbol'
    );
  var 
    str: string;
  begin
    with sentence do
    begin
      str := intToStr(lineCount) + ': ';
      str := str + opname + ' (' + intToStr(opcode) + ')';
      with args[0] do if stringValue <> '' then
        str := str + ', ' + stringValue + ' (' + C_PARAM_TYPES[argType] + ')';
      with args[1] do if stringValue <> '' then
        str := str + ', ' + stringValue + ' (' + C_PARAM_TYPES[argType] + ')';
    end;
    message(str);
  end;

end.
