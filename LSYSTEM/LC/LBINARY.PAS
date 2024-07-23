{
  This unit is in charge of storing all binary info
  related to the build, including the code and also the data.
  It also converts sentences into their binary representation
}
unit
  lbinary;

interface

  uses
    consts, utils, uclasses, types, locale, strings,
    uobject, uexc, ulist, ustream,
    lcommon, lcbase, lsymbols, ltexts, lliteral;

  const
    C_CLASS_ID_Binary = $F012;
    C_SENTENCES_PER_BLOCK = 5;
    C_INSTRUCTIONS_PER_BLOCK = 10;
    C_BYTES_PER_DATA_BLOCK = 256;

  type
    EMetadataKey = (
      EMetadataKeyName,
      EMetadataKeyVersion,
      EMetadataKeyTimestamp,
      EMetadataKeyAuthor,
      EMetadataKeyCompany,
      EMetadataKeyDescription,
      EMetadataKeyOther
    );

    TMetadataEntry = string[100];

    PBinary = ^TBinary;
    TBinary = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure addSentence(const sentence: TSentence);
      function addData(data: pchar; size: TUInt32): TUInt32;
      procedure addMetadata(const key: EMetadataKey; const value: TMetadataEntry);
      procedure addSymbol(const name: TString30; kind: ESymbolKind; value: TUInt32);
      procedure make;
      procedure save(stream: PStream);
    private
      _symbols: PSymbols;          { keeps track of the symbols like labels or defines }
      _sentences: PList;           { the list of non compiled, parsed sentences }
      _instructions: PList;        { the list of compiled instruction blocks }
      _dataBlocks: PList;          { the data bytes such as variables and constants }
      _totalDataBytes: TUInt32;    { how many bytes in total have been added to data section }
      function parameterTypeToValue(parameterType: EParameterType): byte;
      procedure setParameterBinaryValue(const arg: TSentenceArgument; param: PUInt32);
    end;

    PSentenceBlock = ^TSentenceBlock;
    TSentenceBlock = object (TObject)    
      items: array [0..C_SENTENCES_PER_BLOCK-1] of TSentence;
      count: byte;
      constructor init;
    end;

    PInstructionBlock = ^TInstructionBlock;
    TInstructionBlock = object (TObject)    
      items: array [0..C_INSTRUCTIONS_PER_BLOCK-1] of TInstruction;
      count: byte;
      constructor init;
    end;

    PDataBlock = ^TDataBlock;
    TDataBlock = object (TObject)
      data: array [0..C_BYTES_PER_DATA_BLOCK-1] of char;
      first: TUInt32;
      count: byte;
      constructor init;
    end;

implementation
  
  { auxiliar objects }

  constructor TSentenceBlock.init;
  begin
    inherited init;
    count := 0;
  end;

  constructor TInstructionBlock.init;
  begin
    inherited init;
    count := 0;
  end;

  constructor TDataBlock.init;
  begin
    inherited init;
    first := 0;
    count := 0;
  end;

  { TBinary public }

  constructor TBinary.init;
  begin
    inherited init;
    _symbols := new(PSymbols, init);
    _sentences := new(PList, init);
    _instructions := new(PList, init);
    _dataBlocks := new(PList, init);
    _totalDataBytes := 0;
  end;

  destructor TBinary.done;
  begin
    _dataBlocks^.release;
    _instructions^.release;
    _sentences^.release;
    _symbols^.release;
    inherited done;
  end;

  function TBinary.getClassName: string;
  begin
    getClassName := 'TBinary';
  end;

  function TBinary.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Binary;
  end;

  procedure TBinary.addSentence(const sentence: TSentence);
  var
    sentenceBlock: PSentenceBlock;
  begin
    sentenceBlock := PSentenceBlock(_sentences^.getLast);

    if (sentenceBlock = nil) or (sentenceBlock^.count = C_SENTENCES_PER_BLOCK) then
    begin
      sentenceBlock := new(PSentenceBlock, init);
      _sentences^.addObject(sentenceBlock);
      sentenceBlock^.release;
    end;
    with sentenceBlock^ do 
    begin
      items[count] := sentence;
      count := count + 1;
    end;
  end;

  function TBinary.addData(data: pchar; size: TUInt32): TUInt32;
  var
    block: PDataBlock;
    p: pchar;
    position, count, remaining: TUInt32;
  begin
    block := PDataBlock(_dataBlocks^.getLast);
    remaining := size;
    while remaining>0 do
    begin
      if (block = nil) or (block^.count = C_BYTES_PER_DATA_BLOCK) then
      begin
        if block = nil then 
          position := 0 
        else 
          position := block^.first + C_BYTES_PER_DATA_BLOCK;
        block := new (PDataBlock, init);
        block^.first := position;
        _dataBlocks^.addObject(block);
        block^.release;
      end;
      p := block^.data;
      inc(p, block^.count);
      if remaining > C_BYTES_PER_DATA_BLOCK then 
        count := C_BYTES_PER_DATA_BLOCK
      else 
        count := remaining;
      Move(data^, p^, count);
      dec(remaining, count);
      inc(block^.count, count);
    end;
    addData := _totalDataBytes;
    inc(_totalDataBytes, size);
  end;

  procedure TBinary.addMetadata(const key: EMetadataKey; const value: TMetadataEntry);
  begin
  end;

  procedure TBinary.addSymbol(const name: TString30; kind: ESymbolKind; value: TUInt32);
  begin
    _symbols^.addValue(name, kind, value);
  end;

  procedure TBinary.make;
  var
    sentenceBlock: PSentenceBlock;
    instructionBlock: PInstructionBlock;
    sentence: TSentence;
    instruction: PInstruction;
    i: byte;
    totalCount, instructionAddress: TUInt32;
  begin
    msg(EMsgNormal, C_STR_MAKING, '');
    _sentences^.moveToStart;
    sentenceBlock := PSentenceBlock(_sentences^.getObjectAtCursor);

    instructionBlock := PInstructionBlock(_instructions^.getLast);
    totalCount := 0;
    while sentenceBlock<>nil do
    begin
      i:=0;
      while i<sentenceBlock^.count do
      begin        

        if (instructionBlock = nil) or (instructionBlock^.count = C_INSTRUCTIONS_PER_BLOCK) then
        begin
          instructionBlock := new(PInstructionBlock, init);
          _instructions^.addObject(instructionBlock);
          instructionBlock^.release;
        end;

        with instructionBlock^ do
        begin
          instruction := @items[count];
          inc(count);
        end;

        with sentenceBlock^.items[i] do
        begin
          instructionAddress := totalCount * sizeof(TInstruction);
          if labelName<>'' then 
            _symbols^.addValue(labelName, ESymbolLabel, instructionAddress);
          instruction^.header.opcode := opcode;
          instruction^.header.params := 
             (parameterTypeToValue(args[0].argType) shl 4) 
             or parameterTypeToValue(args[1].argType);

          setParameterBinaryValue(args[0], @instruction^.param0);
          setParameterBinaryValue(args[1], @instruction^.param1);
        end;

        inc(totalCount);
        inc(i);
      end;
      _sentences^.moveForward;
      sentenceBlock := PSentenceBlock(_sentences^.getObjectAtCursor);
    end;

    if _symbols^.getUnknownCount > 0 then
      msg(EMsgFatal, C_STR_ERR_UNDEFINED_SYMBOL, _symbols^.getFirstUnknownName);

  end;

  procedure TBinary.save(stream: PStream);
  var
    instructionBlock: PInstructionBlock;
    i: byte;
  begin
    msg(EMsgNormal, C_STR_SAVING, '');
    stream^.write(@C_BINARY_SIGNATURE, sizeof(C_BINARY_SIGNATURE));
    _instructions^.moveToStart;
    instructionBlock := PInstructionBlock(_instructions^.getObjectAtCursor);
    while instructionBlock<>nil do
      with instructionBlock^ do
      begin
        i := 0;
        while i<count do
        begin
          stream^.write(@items[i], sizeof(TInstruction));
          inc(i);
        end;      
        _instructions^.moveForward;  
        instructionBlock := PInstructionBlock(_instructions^.getObjectAtCursor);
      end;
  end;

  { TBinary private }

  function TBinary.parameterTypeToValue(parameterType: EParameterType): byte;
  const
    C_VALUES : array[EParameterType] of byte = (
        C_PARAMETER_LITERAL,   { Unknown }
        C_PARAMETER_LITERAL,   { Literal }
        C_PARAMETER_REGISTER,  { Register }
        C_PARAMETER_ADDRESS,   { Address }
        C_PARAMETER_POINTER,   { Pointer }
        C_PARAMETER_LITERAL,   { Symbol }
        C_PARAMETER_LITERAL,   { Definition }
        C_PARAMETER_ADDRESS    { Variable }
    );
  begin
    parameterTypeToValue := C_VALUES[parameterType];
  end;

  procedure TBinary.setParameterBinaryValue(const arg: TSentenceArgument; param: PUInt32);
  var
    success: boolean;
    symbolKind: ESymbolKind;
  begin
    with arg do case argType of
      EParameterTypeLiteral, EParameterTypeAddress: 
        param^ := arg.intValue;

      EParameterTypeRegister: 
        param^ := arg.registerCode;

      EParameterTypePointer: 
        param^ := (longint(arg.offset) shl 16) or arg.registerCode;

      EParameterTypeSymbol:
      begin
        success := _symbols^.getValue(arg.stringValue, symbolKind, param^);
        if not success then 
          _symbols^.addUnknownValue(arg.stringValue, param);
      end;
    
      EParameterTypeUnknown:
      begin
        { this happens when there is no parameter (an empty argument) }
        { by default we simply store 0 }
        param^ := 0;
      end;

    end;
  end;

  { Other }

end.
