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
      procedure addData(data: pointer; size: longint);
      procedure addMetadata(const key: EMetadataKey; const value: TMetadataEntry);
      procedure make;
      procedure save(stream: PStream);
    private
      _symbols: PSymbols;          { keeps track of the symbols like labels or defines }
      _sentences: PList;           { the list of non compiled, parsed sentences }
      _instructions: PList;              { the list of compiled instruction blocks }
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

  { non-object functions } 

  function parameterTypeToValue(parameterType: EParameterType): byte;
  const
    C_VALUES : array[EParameterType] of byte = (
        C_PARAMETER_LITERAL,
        C_PARAMETER_LITERAL,
        C_PARAMETER_REGISTER,
        C_PARAMETER_ADDRESS,
        C_PARAMETER_POINTER,
        C_PARAMETER_LITERAL
    );
  begin
    parameterTypeToValue := C_VALUES[parameterType];
  end;

  function getParameterBinaryValue(const arg: TSentenceArgument): TUInt32;
  var
    result: TUInt32;
    i, j, code, bitSize: byte;
    token: TString30;
    success: boolean;
  begin
    with arg do case argType of
      EParameterTypeLiteral, EParameterTypeAddress: 
      begin
        success := any2int(stringValue, result);
        if not success then error(strformatn(C_STR_UNRECOGNIZABLE_ARGUMENT, stringValue));
      end;

      EParameterTypeRegister:
      begin
        success := getRegisterInfoByName(stringValue, code, bitSize);
        if not success then error(strformatn(C_STR_UNRECOGNIZABLE_ARGUMENT, stringValue));
        result := code;
      end;

      EParameterTypePointer:
      begin
        i := pos('[', stringValue);
        j := pos(']', stringValue);
        token := copy(stringValue, i+1, j-i-1);
        success := getRegisterInfoByName(token, code, bitSize);
        if not success then error(strformatn(C_STR_UNRECOGNIZABLE_ARGUMENT, stringValue));
        result := (offset shr 16) and code;
      end;

    else
      {TO DO: EParameterTypeUnknown, EParameterTypeSymbol}
      result := 0;
    end;
    getParameterBinaryValue := result;
  end;

  { TBinary public }

  constructor TBinary.init;
  begin
    inherited init;
    _symbols := new(PSymbols, init);
    _sentences := new(PList, init);
    _instructions := new(PList, init);
  end;

  destructor TBinary.done;
  begin
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

  procedure TBinary.addData(data: pointer; size: longint);
  begin
  end;

  procedure TBinary.addMetadata(const key: EMetadataKey; const value: TMetadataEntry);
  begin
  end;

  procedure TBinary.make;
  var
    sentenceBlock: PSentenceBlock;
    instructionBlock: PInstructionBlock;
    sentence: TSentence;
    instruction: TInstruction;
    i: byte;
  begin
    message(C_STR_MAKING);
    _sentences^.moveToStart;
    sentenceBlock := PSentenceBlock(_sentences^.getObjectAtCursor);

    instructionBlock := PInstructionBlock(_instructions^.getLast);

    while sentenceBlock<>nil do
    begin
      i:=0;
      while i<sentenceBlock^.count do
      begin
        with sentenceBlock^.items[i] do
        begin
          instruction.header.opcode := opcode;
          instruction.header.params := 
             (parameterTypeToValue(args[0].argType) shl 4) 
             or parameterTypeToValue(args[1].argType);
          instruction.param0 := getParameterBinaryValue(args[0]);
          instruction.param1 := getParameterBinaryValue(args[1]);
        end;

        if (instructionBlock = nil) or (instructionBlock^.count = C_INSTRUCTIONS_PER_BLOCK) then
        begin
          instructionBlock := new(PInstructionBlock, init);
          _instructions^.addObject(instructionBlock);
          instructionBlock^.release;
        end;
        with instructionBlock^ do
        begin
          items[count] := instruction;
          count := count + 1;
        end;

        inc(i);
      end;
      _sentences^.moveForward;
      sentenceBlock := PSentenceBlock(_sentences^.getObjectAtCursor);
    end;
  end;

  procedure TBinary.save(stream: PStream);
  var
    instructionBlock: PInstructionBlock;
    i: byte;
  begin
    message(C_STR_SAVING);
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

  { Other }

end.
