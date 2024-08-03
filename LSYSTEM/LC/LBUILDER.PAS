unit
  lbuilder;

interface

  uses
    consts, utils, types, locale, math, uclasses, strings,
    uobject, uexc, ustream, ufstream, ucstream, ustdout,
    lcommon, lcbase, lsrccode, lcparser, ldparser, ltexts, lbinary;

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
      procedure receiveMessage(msg: PObjectMessage); virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _sourceStream: PStream;      { stream used to read the source code }
      _targetStream: PStream;      { stream used to write the binary code }
      _config: TBuilderConfig;     { other configuration settings }
      _sourceCode: PSourceCode;    { contains the full source code to be compiled }
      _binary: PBinary;            { contains the full binary code and data }
      procedure buildData;
      procedure buildCode;
    end;

implementation

  { TBuilder public }

  constructor TBuilder.init;
  begin
    inherited init;
    fillChar(_config, sizeof(TBuilderConfig), 0);
    _sourceStream := nil;
    _targetStream := nil;
    _binary := new(PBinary, init);
    _sourceCode := nil;
  end;

  destructor TBuilder.done;
  begin
    if _sourceStream<>nil then _sourceStream^.release;
    if _targetStream<>nil then _targetStream^.release;
    _binary^.release;
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
  const
    C_DATA_SECTION_HEADER = '.data';
    C_CODE_SECTION_HEADER = '.code';
  var
    line: string;
  begin
    { prepare everything to compile }
    if _sourceStream = nil then msg(EMsgFatal, C_STR_SOURCE_NOT_SET, '');
    if _targetStream = nil then msg(EMsgFatal, C_STR_TARGET_NOT_SET, '');
    msg(EMsgNormal, C_STR_BUILDING, '');
    _sourceCode := new(PSourceCode, initWithStream(_sourceStream));
    if not _sourceCode^.isValid then msg(EMsgFatal, C_STR_READ_ERROR, '');

    { find section headers }
    line := '';
    while line = '' do line := trim(_sourceCode^.readLine);

    if line = C_DATA_SECTION_HEADER then
    begin
      buildData;
      line := '';
      while line = '' do line := trim(_sourceCode^.readLine);
    end;
    
    if line = C_CODE_SECTION_HEADER then
    begin
      buildCode;
      { create the binary }
      _binary^.make;
    end else
      msg(EMsgFatal, C_STR_ERR_INVALID_SECTION_HEADER, line);

    msg(EMsgNormal, C_STR_TOTAL_CODE_BYTES, intToStr(_binary^.getTotalCodeBytes));
    msg(EMsgNormal, C_STR_TOTAL_DATA_BYTES, intToStr(_binary^.getTotalDataBytes));
    _binary^.save(_targetStream);

    { release objects and present success message }
    _sourceCode^.release;
    _sourceCode := nil;
    msg(EMsgGood, C_STR_BUILD_SUCCESSFUL, '');
    writeln;
  end;

  procedure TBuilder.buildData;
  var
    dataParser: PDataParser;    { reads and validates the data section }
  begin
    { parse the data section }
    dataParser := new(PDataParser, initWithSourceCode(_sourceCode));
    dataParser^.setDelegate(@self);
    dataParser^.parse;
    dataParser^.release;
  end;

  procedure TBuilder.buildCode;
  var
    codeParser: PCodeParser;
    sentence: TSentence;
  begin
    { parse the code section } 
    codeParser := new(PCodeParser, initWithSourceCode(_sourceCode));
    while not codeParser^.isDone do
    begin
      if codeParser^.parseSentence(sentence) then
      begin
        _binary^.addSentence(sentence);
      end;
    end;
    codeParser^.release;
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

  procedure TBuilder.receiveMessage(msg: PObjectMessage); 
  var
    symbol: PSymbol;
    memoryLocation: TUInt32;
  begin 
    case msg^.opcode of

      C_DELEGATE_ADD_DEFINITION:
      begin
        symbol := PSymbol(msg^.payload);
        _binary^.addSymbol(symbol^.name, ESymbolDefinition, symbol^.value);
      end;

      C_DELEGATE_ADD_VARIABLE:
      begin
        symbol := PSymbol(msg^.payload);
        memoryLocation := _binary^.addData(@(symbol^.value), symbol^.dataSize);
        _binary^.addSymbol(symbol^.name, ESymbolVariable, memoryLocation);
      end;      

    end;    
  end;

  { TBuilder private }

end.
