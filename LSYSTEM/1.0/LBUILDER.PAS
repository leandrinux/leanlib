unit
  lbuilder;

interface

  uses
    consts, utils, types, locale, math, uclasses, strings,
    uobject, uexc, ustream, ufstream, ucstream, ustdout,
    lcommon, lcbase, lsrccode, lparser, ltexts, lbinary;

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
      procedure printSentence(const sentence: TSentence);
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
    parser: PParser;            { reads and validates the source code }
  begin
    message(strformatn(C_STR_BUILDING, ''));
    if sourceCode <> nil then sourceCode^.release;
    sourceCode := new(PSourceCode, initWithStream(_sourceStream));
    if not sourceCode^.isValid then error(C_STR_READ_ERROR);
    parser := new(PParser, initWithSourceCode(sourceCode));
    binary := new(PBinary, init);
    count := 0;
    while not sourceCode^.isReadComplete do
    begin
      parser^.readSentence(sentence);
      parser^.validateSentence(sentence);
      if _config.isVerbose then printSentence(sentence);
      binary^.addSentence(sentence);
      inc(count);
    end;
    binary^.make;
    binary^.save(_targetStream);
    binary^.release;
    parser^.release;
    sourceCode^.release;
    message(strformatn(C_STR_SENTENCES_PROC, intToStr(count)));
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

  procedure TBuilder.printSentence(const sentence: TSentence);
  const 
    C_PARAM_TYPES : array[EParameterType] of string[10] = (
      'unknown', 'literal', 'register', 'address', 'pointer', 'symbol'
    );
  begin
    with sentence do
    begin
      message(strformatn(C_STR_SENTENCE_OPERATION, opname + #0 + intToStr(opcode)));
      if param0 <> '' then
        message(strformatn(C_STR_SENTENCE_PARAMETER, param0 + #0 + C_PARAM_TYPES[paramType0]));
      if param1 <> '' then
        message(strformatn(C_STR_SENTENCE_PARAMETER, param1 + #0 + C_PARAM_TYPES[paramType1]));
      message(C_CR + C_LF);
    end;
  end;

end.
