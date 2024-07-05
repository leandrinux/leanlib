{
  this unit performs the parsing of sentences and other
  components of the source code
}
unit
  lparser;

interface

  uses
    consts, utils, uclasses, types, locale, strings,
    uobject, uexc, lliteral, lcommon, lcbase, lsrccode, ltexts;

  const
    C_CLASS_ID_Parser = $F011;

  type
    PParser = ^TParser;
    TParser = object (TObject)
    public
      constructor initWithSourceCode(sourceCode: PSourceCode);
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure readSentence(var sentence: TSentence);
      procedure validateSentence(var sentence: TSentence);
    private
      _sourceCode: PSourceCode;
      procedure parsePointers(var sentence: TSentence);
      procedure parsePointer(var param: TString30; var paramOffset: TInt16);
    end;

implementation

  { TParser public }

  constructor TParser.initWithSourceCode(sourceCode: PSourceCode);
  begin
    inherited init;
    _sourceCode := sourceCode;
    _sourceCode^.retain;
  end;

  destructor TParser.done;
  begin
    _sourceCode^.release;
    inherited done;
  end;

  function TParser.getClassName: string;
  begin
    getClassName := 'TParser';
  end;

  function TParser.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Parser;
  end;

  procedure TParser.readSentence(var sentence: TSentence);
  type
    EState = (
      EStateStart,
      EStateSkipSpaces,
      EStateSkipSpacesAndCRLF,
      EStateReadOperationOrLabel,
      EStateReadOperation,
      EStateReadFirstParam,
      EStateReadSecondParam,
      EStateSuccess,
      EStateFailure
    );
  var
    ch, lookAhead: char;
    state: EState;
    nextState: EState;
    token: string;
  begin
    state := EStateStart;
    while (state <> EStateSuccess) and (state <> EStateFailure) do
    begin
      case state of
        EStateStart:
        begin
          fillchar(sentence, sizeof(sentence), 0);
          token := '';
          state := EStateSkipSpacesAndCRLF;
          nextState := EStateReadOperationOrLabel;
          _sourceCode^.readChar(ch, lookAhead);
        end;

        EStateSkipSpaces:
        begin
          if not (ch in [' ', #9]) then 
            state := nextState
          else
            _sourceCode^.readChar(ch, lookAhead);
        end;

        EStateSkipSpacesAndCRLF:
        begin
          if not (ch in [' ', C_CR, C_LF, #9]) then 
            state := nextState
          else
            _sourceCode^.readChar(ch, lookAhead);
        end;

        EStateReadOperationOrLabel:
        begin
          case ch of
            C_CR, C_LF: begin end;
            ':': begin
              sentence.labelName := token;
              token := '';
              state := EStateSkipSpacesAndCRLF;
              nextState := EStateReadOperation;
            end;
            ' ', #0: begin
              sentence.labelName := '';
              sentence.opname := token;
              token := '';
              if ch = #0 then
                state := EStateSuccess
              else begin
                state := EStateSkipSpaces;
                nextState := EStateReadFirstParam;
              end;
            end;
          else
            token := token + ch;
          end;
          _sourceCode^.readChar(ch, lookAhead);
        end;

        EStateReadOperation:
        begin
          case ch of
            C_LF, C_CR: begin end;
            ' ': begin
              sentence.opname := token;
              token := '';
              state := EStateSkipSpaces;
              nextState := EStateReadFirstParam;
            end;
          else
            token := token + ch;
          end;
          _sourceCode^.readChar(ch, lookAhead);
        end;

        EStateReadFirstParam:
        begin
          case ch of
            C_LF:
            begin
              sentence.args[0].stringValue := token;
              token := '';
              state := EStateSuccess;
            end;
            C_CR: begin end;
            ',': begin
              sentence.args[0].stringValue := token;
              token := '';
              state := EStateSkipSpaces;
              nextState := EStateReadSecondParam;
            end;
          else
            token := token + ch;
          end;
          _sourceCode^.readChar(ch, lookAhead);
        end;

        EStateReadSecondParam:
        begin
          case ch of
            C_CR: begin end;
            ' ', C_LF, #0: begin
              sentence.args[1].stringValue := token;
              token := '';
              state := EStateSuccess;
            end;
          else
            token := token + ch;
          end;
          if ch<>C_LF then _sourceCode^.readChar(ch, lookAhead);
        end;
      end;
    end;

    if state = EStateSuccess then
    begin
      with sentence.args[0] do argType := getParameterType(stringValue);
      with sentence.args[1] do argType := getParameterType(stringValue);
      parsePointers(sentence);
    end;
  end;

  procedure TParser.validateSentence(var sentence: TSentence);
  const 
    { these instructions do not support a literal as first parameter }
    C_OPCODES_NO_FIRST_LITERAL: set of byte = [
      C_MOV, C_ADD, C_SUB, C_MUL, C_DIV, C_SHL, C_SHR, 
      C_FADD, C_FSUB, C_FMUL, C_FDIV, C_AND, C_OR, C_NOT, 
      C_XOR, C_JMP, C_JZ, C_JP, C_JN, C_JNZ, C_CALL
    ];

    { these instructions do not support a literal as second parameter }
    C_OPCODES_NO_SECOND_LITERAL: set of byte = [
      C_JE, C_JG, C_JL
    ];

    { these instructions cannot have a register in the first parameter and a
      literal on the second, where the register has a smaller bitsize than the literal }
    C_OPCODES_LITERAL_BITSIZE_CHK: set of byte = [ 
      C_MOV, C_ADD, C_SUB, C_MUL, C_DIV, 
      C_FADD, C_FSUB, C_FMUL, C_FDIV, C_AND, 
      C_OR, C_NOT, C_XOR
    ];

  var
    count: byte;
    success: boolean;
    sentenceParamCount: byte;
  begin
    with sentence do 
    begin
      { validate operation name exists }
      success := getOpcodeInfoByName(opname, opcode, count);
      if not success then 
      begin
        writeln(strformatn(C_STR_UNRECOGNIZED_OPERATION, intToStr(_sourceCode^.lineNumber)));
        halt(1);
      end;

      { validate number of arguments } 
      sentenceParamCount := 0;
      if args[0].stringValue <> '' then inc(sentenceParamCount);
      if args[1].stringValue <> '' then inc(sentenceParamCount);
      if sentenceParamCount <> count then
      begin      
        writeln(strformatn(C_STR_OPERATION_EXPECTS_N_PARAM, intToStr(count)));
        halt(1);
      end;

      { check valid parameters according to operation }
      if (opcode in C_OPCODES_NO_FIRST_LITERAL) and (args[0].argType = EParameterTypeLiteral) then
      begin
        writeln(strformatn(C_STR_1ST_LITERAL_UNSUPPORTED, opname));
        halt(1);
      end;

      if (opcode in C_OPCODES_NO_SECOND_LITERAL) and (args[1].argType = EParameterTypeLiteral) then
      begin
        writeln(strformatn(C_STR_2ND_LITERAL_UNSUPPORTED, opname));
        halt(1);
      end;

      { check that the left size bit size is equal or greater than the right size bit size }
      if (args[0].argType = EParameterTypeRegister) 
          and (args[1].argType in [EParameterTypeLiteral, EParameterTypeRegister]) 
          and (opcode in C_OPCODES_LITERAL_BITSIZE_CHK) 
          and (getBitSize(args[0].stringValue, args[0].argType) < getBitSize(args[1].stringValue, args[1].argType)) then
      begin
        writeln(C_STR_REGISTER_CANT_FIT);
        halt(1);
      end;

      { check that the second parameter of OUT is 8-bit and no more }
      if (opcode = C_OUT) and ( 
        (args[1].argType <> EParameterTypeRegister) or (getBitSize(args[1].stringValue, args[1].argType)<>8) 
      ) then
      begin
        writeln(C_STR_OUT_EXPECTS_8BIT);
        halt(1);
      end;

    end;
  end;

  procedure TParser.parsePointers(var sentence: TSentence);
  begin
    with sentence do 
    begin
      with args[0] do if argType = EParameterTypePointer then parsePointer(stringValue, offset);
      with args[1] do if argType = EParameterTypePointer then parsePointer(stringValue, offset);
    end;
  end;

  procedure TParser.parsePointer(var param: TString30; var paramOffset: TInt16);
  var 
    i, j: byte;
    success: boolean;
    var token: TString30;
    value: TUInt32;
  begin
    j := pos(']', param);
    i := pos('+', param);
    if i = 0 then i := pos('-', param);
    if i = 0 then
    begin
      paramOffset := 0;
    end else begin
      token := copy(param, i+1, j-i-1);
      success := any2int(token, value);
      if not success then error(C_STR_INVALID_POINTER_CONSTANT);
      if param[i] = '-' then value := -value;
      if (value<-32768) or (value>32767) then error(C_STR_INVALID_POINTER_CONSTANT_RANGE);
      paramOffset := value;
    end;
  end;

  { Other }

end.
