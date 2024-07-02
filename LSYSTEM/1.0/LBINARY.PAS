{
  This unit is in charge of storing all binary info
  related to the build, including the code and also the data.
  It also converts sentences into their binary representation
}
unit
  lbinary;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ulist,
    lcommon, lcbase, lsymbols, ltexts;

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
      procedure save(const filename: string);
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
    if _sentences^.getCount = 0 then
    begin
      sentenceBlock := new(PSentenceBlock, init);
      _sentences^.addObject(sentenceBlock);
      sentenceBlock^.release;
    end else begin
      sentenceBlock := PSentenceBlock(_sentences^.getLast);
      if sentenceBlock^.count = C_SENTENCES_PER_BLOCK then
      begin
        sentenceBlock := new(PSentenceBlock, init);
        _sentences^.addObject(sentenceBlock);
        sentenceBlock^.release;
      end;
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
    sentence: TSentence;
    instruction: TInstruction;
    i: byte;
  begin
    message(C_STR_MAKING);
    _sentences^.moveToStart;
    sentenceBlock := PSentenceBlock(_sentences^.getObjectAtCursor);
    _sentences^.moveForward;
    while sentenceBlock<>nil do
    begin
      i:=0;
      while i<sentenceBlock^.count do
      begin
        with sentenceBlock^.items[i] do
        begin
          writeln(opname);
          instruction.header.opcode := opcode;
          instruction.header.params := (parameterTypeToValue(paramType1) shl 4) or parameterTypeToValue(paramType0);
          instruction.param0 := 0; { to do }
          instruction.param1 := 0; { to do }
        end;
        inc(i);
      end;
      sentenceBlock := PSentenceBlock(_sentences^.getObjectAtCursor);
      _sentences^.moveForward;
    end;
  end;

  procedure TBinary.save(const filename: string);
  begin
    message(C_STR_SAVING);
  end;

  { TBinary private }

  { Other }

end.
