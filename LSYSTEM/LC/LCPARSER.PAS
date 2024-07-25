{
  this unit performs the parsing of sentences and other
  components of the source code
}
unit
  lcparser;

interface

  uses
    ascii, consts, utils, uclasses, types, locale, strings,
    uobject, uexc, lliteral, lcommon, lcbase, lsrccode, ltexts;

  const
    C_CLASS_ID_CODE_PARSER = $F011;

  type
    PCodeParser = ^TCodeParser;
    TCodeParser = object (TObject)
    public
      constructor initWithSourceCode(sourceCode: PSourceCode);
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      function isDone: boolean;
      function parseSentence(var sentence: TSentence): boolean;
    private
      _sourceCode: PSourceCode;
      procedure fatalError(const str, args: string);
      procedure validateSentence(var sentence: TSentence);
      procedure parseArguments(var sentence: TSentence);
      procedure parseLiteral(var arg: TSentenceArgument);
      procedure parseAddress(var arg: TSentenceArgument);
      procedure parseRegister(var arg: TSentenceArgument);
      procedure parsePointer(var arg: TSentenceArgument);
    end;

implementation

  { TCodeParser public }

  constructor TCodeParser.initWithSourceCode(sourceCode: PSourceCode);
  begin
    inherited init;
    _sourceCode := sourceCode;
    _sourceCode^.retain;
  end;

  destructor TCodeParser.done;
  begin
    _sourceCode^.release;
    inherited done;
  end;

  function TCodeParser.getClassName: string;
  begin
    getClassName := 'TCodeParser';
  end;

  function TCodeParser.getClassId: word;
  begin
    getClassId := C_CLASS_ID_CODE_PARSER;
  end;

  function TCodeParser.isDone: boolean;
  begin
    isDone := _sourceCode^.isReadComplete;
  end;

  function TCodeParser.parseSentence(var sentence: TSentence): boolean;
  type
    EState = (
      EStateStart,
      EStateSkipSpacesBeforeFirst,
      EStateSkipLineBeforeFirst,
      EStateGetFirstToken,
      EStateSkipSpacesBeforeSecond,
      EStateSkipLineBeforeSecond,
      EStateGetSecondToken,
      EStateSkipSpacesBeforeThird,
      EStateSkipLineBeforeThird,
      EStateGetThirdToken,
      EStateError,
      EStateSuccess
    );
  const 
    C_IDENTIFIER_CHARS = ['A'..'Z', 'a'..'z', '_', '0'..'9'];
    C_SPACING_CHARS = [C_SPACE, C_TAB, C_CR, C_LF];
    C_END_STATES = [EStateSuccess, EStateError];
  var
    ch: char;
    state: EState;
    token: string;
  begin
    state := EStateStart;
    with sentence do while not (state in C_END_STATES) do
    begin
      case state of
        EStateStart:
        begin
          fillchar(sentence, sizeof(sentence), 0);
          token := '';
          state := EStateSkipSpacesBeforeFirst;
          ch := _sourceCode^.readChar;
        end;

        EStateSkipSpacesBeforeFirst:
        begin
          if ch in C_IDENTIFIER_CHARS then
            state := EStateGetFirstToken
          else if ch in C_SPACING_CHARS then
            ch := _sourceCode^.readChar
          else if ch = C_HASH then
            state := EStateSkipLineBeforeFirst
          else
            state := EStateError
        end;

        EStateSkipLineBeforeFirst:
        begin
          if ch in [C_CR, C_LF] then
            state := EStateSkipSpacesBeforeFirst
          else
            ch := _sourceCode^.readChar;
        end;

        EStateGetFirstToken:
        begin
          if ch in C_IDENTIFIER_CHARS then
            token := token + ch
          else if ch = ':' then 
          begin
            if labelName <> '' then 
              state := EStateError
            else begin
              labelName := token;
              token := '';
              state := EStateSkipSpacesBeforeFirst;
            end;
          end else if ch in C_SPACING_CHARS then
          begin
            opname := token;
            token := '';
            state := EStateSkipSpacesBeforeSecond;
          end;
          ch := _sourceCode^.readChar
        end;

        EStateSkipSpacesBeforeSecond:
        begin
          if ch in [C_SPACE, C_TAB, C_LF] then
            ch := _sourceCode^.readChar
          else if ch = C_HASH then
            state := EStateSkipLineBeforeSecond
          else if ch in [C_CR, C_NULL] then
            state := EStateSuccess            
          else 
            state := EStateGetSecondToken;
        end;

        EStateSkipLineBeforeSecond:
        begin
          if ch in [C_CR, C_LF] then
            state := EStateSkipSpacesBeforeSecond
          else
            ch := _sourceCode^.readChar;
        end;

        EStateGetSecondToken:
        begin
          if ch = C_QUOTE then
          begin
            ch := _sourceCode^.readChar;
            sentence.args[0].stringValue := '''' + ch + '''';
            ch := _sourceCode^.readChar;
            if ch = C_QUOTE then
            begin
              token := '';
              state := EStateSkipSpacesBeforeThird;
            end else
              state := EStateError;
          end else if ch in [C_COMMA, C_SPACE, C_NULL, C_TAB, C_LF] then
          begin
            sentence.args[0].stringValue := token;
            token := '';
            state := EStateSkipSpacesBeforeThird;
          end else if ch in [C_CR, C_NULL, C_HASH] then
          begin
            sentence.args[0].stringValue := token;
            token := '';
            state := EStateSuccess
          end else
            token := token + ch;
          ch := _sourceCode^.readChar
        end;

        EStateSkipSpacesBeforeThird:
        begin
          if ch in [C_SPACE, C_TAB, C_LF] then
            ch := _sourceCode^.readChar
          else if ch = C_HASH then
            state := EStateSkipLineBeforeThird
          else if ch in [C_CR, C_NULL] then
            state := EStateSuccess
          else 
            state := EStateGetThirdToken;
        end;

        EStateSkipLineBeforeThird:
        begin
          if ch in [C_CR, C_LF] then
            state := EStateSkipSpacesBeforeThird
          else
            ch := _sourceCode^.readChar;
        end;

        EStateGetThirdToken:
        begin
          if ch = C_QUOTE then
          begin
            ch := _sourceCode^.readChar;
            sentence.args[1].stringValue := '''' + ch + '''';
            ch := _sourceCode^.readChar;
            if ch = C_QUOTE then
            begin
              token := '';
              state := EStateSuccess;
            end else
              state := EStateError;
          end else if ch in [C_SPACE, C_TAB, C_CR, C_LF, C_NULL] then
          begin
            sentence.args[1].stringValue := token;
            token := '';
            state := EStateSuccess;
          end else
            token := token + ch;
          ch := _sourceCode^.readChar;
        end;

      end;
    end;

    if state = EStateSuccess then
    begin
      parseArguments(sentence);
      validateSentence(sentence);
      parseSentence := true;
    end else
      parseSentence := false;
  end;

  procedure TCodeParser.fatalError(const str, args: string);
  begin
    msg(EMsgFatal, str, intToStr(_sourceCode^.lineNumber) + C_NULL + args);
  end;

  procedure TCodeParser.validateSentence(var sentence: TSentence);
  const 
    { these instructions do not support a literal as first parameter }
    C_OPCODES_NO_FIRST_LITERAL: set of byte = [
      C_MOV, C_ADD, C_SUB, C_MUL, C_DIV, C_MOD, C_SHL, C_SHR, 
      C_FADD, C_FSUB, C_FMUL, C_FDIV, C_AND, C_OR, C_NOT, 
      C_XOR, C_JMP, C_JZ, C_JP, C_JN, C_JNZ, C_CALL
    ];

    { these instructions do not support a symbol as first parameter }
    C_OPCODES_NO_FIRST_SYMBOL: set of byte = [
      C_MOV, C_ADD, C_SUB, C_MUL, C_DIV, C_MOD, C_SHL, C_SHR, 
      C_FADD, C_FSUB, C_FMUL, C_FDIV, 
      C_AND, C_OR, C_NOT, C_XOR
    ];

    { these instructions do not support a literal as second parameter }
    C_OPCODES_NO_SECOND_LITERAL: set of byte = [
      C_JE, C_JG, C_JL
    ];

    { these instructions cannot have a register in the first parameter and a
      literal on the second, where the register has a smaller bitsize than the literal }
    C_OPCODES_LITERAL_BITSIZE_CHK: set of byte = [ 
      C_MOV, C_ADD, C_SUB, C_MUL, C_DIV, C_MOD,
      C_FADD, C_FSUB, C_FMUL, C_FDIV, C_AND, 
      C_OR, C_NOT, C_XOR
    ];

    { these opcodes change the value of the first parameter }
    C_OPCODES_CHANGE_FIRST_ARG: set of byte = [
      C_MOV, C_ADD, C_SUB, C_MUL, C_DIV, C_MOD,
      C_FADD, C_FSUB, C_FMUL, C_FDIV, 
      C_AND, C_OR, C_NOT, C_XOR, C_SHL, C_SHR,
      C_POP
    ];

    { these opcodes change the value of the second parameter }
    C_OPCODES_CHANGE_SECOND_ARG: set of byte = [
      C_IN
    ];

    { these registers are considered read-only and cannot be modified }
    C_REGISTERS_READ_ONLY: set of byte = [
      C_SS, C_IP, C_CC
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
        fatalError(C_STR_ERR_UNRECOGNIZED_OPERATION, opname);

      { validate number of arguments } 
      sentenceParamCount := 0;
      if args[0].stringValue <> '' then inc(sentenceParamCount);
      if args[1].stringValue <> '' then inc(sentenceParamCount);
      if sentenceParamCount <> count then
        fatalError(C_STR_ERR_OPERATION_EXPECTS_N_PARAM, 
          opname + C_NULL + intToStr(count)
        );

      { check valid parameters according to operation }
      if (opcode in C_OPCODES_NO_FIRST_LITERAL) and 
        (args[0].argType = EParameterTypeLiteral) 
      then
        fatalError(C_STR_ERR_1ST_PARAM_UNSUPPORTED, opname + C_NULL + args[0].stringValue);

      if (opcode in C_OPCODES_NO_FIRST_SYMBOL) and 
        (args[0].argType = EParameterTypeSymbol) 
      then
        fatalError(C_STR_ERR_1ST_PARAM_UNSUPPORTED, opname + C_NULL + args[0].stringValue);

      if (opcode in C_OPCODES_NO_SECOND_LITERAL) and 
        (args[1].argType = EParameterTypeLiteral) 
      then
        fatalError(C_STR_ERR_2ND_PARAM_UNSUPPORTED, opname + C_NULL + args[1].stringValue);

      { check that the left size bit size is equal or greater than the right size bit size }
      if (args[0].argType = EParameterTypeRegister) and 
        (args[1].argType in [EParameterTypeLiteral, EParameterTypeRegister]) and
        (opcode in C_OPCODES_LITERAL_BITSIZE_CHK) and
        (getBitSize(args[0].stringValue, args[0].argType) < getBitSize(args[1].stringValue, args[1].argType))
      then
        fatalError(C_STR_ERR_REGISTER_CANT_FIT, args[0].stringValue + C_NULL + args[1].stringValue);

      { check that the second parameter of OUT is 8-bit and no more }
      if (opcode = C_OUT) and (getBitSize(args[1].stringValue, args[1].argType)<>8) then
        fatalError(C_STR_ERR_OUT_EXPECTS_8BIT, args[1].stringValue);

      { check that read only registers are not being modified }
      if (opcode in C_OPCODES_CHANGE_FIRST_ARG) and 
        (args[0].registerCode in C_REGISTERS_READ_ONLY)
        then
        fatalError(C_STR_ERR_REGISTER_IS_READONLY, args[0].stringValue);

      if (opcode in C_OPCODES_CHANGE_SECOND_ARG) and 
        (args[1].registerCode in C_REGISTERS_READ_ONLY)
        then
        fatalError(C_STR_ERR_REGISTER_IS_READONLY, args[1].stringValue);

      { CS can only be modified with MOV}
      if (args[0].registerCode = C_CS) and (opcode <> C_MOV) then
        fatalError(C_STR_ERR_CS_CAN_ONLY_BE_MODIFIED, '');

      { IN only accepts registers as second parameter}
      if (opcode = C_IN) and (args[1].argType <> EParameterTypeRegister) then
        fatalError(C_STR_ERR_IN_REQUIRES_REGISTER, '');

    end;
  end;

  procedure TCodeParser.parseArguments(var sentence: TSentence);
  begin
    { determine the type of each argument }
    with sentence.args[0] do argType := getParameterType(stringValue);
    with sentence.args[1] do argType := getParameterType(stringValue);

    { according to type, interpret the value or values for each one}
    with sentence do case args[0].argType of
      EParameterTypeLiteral: parseLiteral(args[0]);
      EParameterTypeAddress: parseAddress(args[0]);
      EParameterTypeRegister: parseRegister(args[0]);
      EParameterTypePointer: parsePointer(args[0]);
    end;
    with sentence do case args[1].argType of
      EParameterTypeLiteral: parseLiteral(args[1]);
      EParameterTypeAddress: parseAddress(args[1]);
      EParameterTypeRegister: parseRegister(args[1]);
      EParameterTypePointer: parsePointer(args[1]);
    end;
  end;

  procedure TCodeParser.parseLiteral(var arg: TSentenceArgument);
  var
    success: boolean;
  begin
    if (length(arg.stringValue) = 3) and 
      (arg.stringValue[1] = '''') and
      (arg.stringValue[3] = '''') then
    begin
      arg.intValue := ord(arg.stringValue[2]);
      success := true;
    end else
      success := any2int(arg.stringValue, arg.intValue);
    if not success then 
      msg(EMsgFatal, C_STR_UNRECOGNIZABLE_ARGUMENT, arg.stringValue);
  end;

  procedure TCodeParser.parseAddress(var arg: TSentenceArgument);
  var
    success: boolean;
    token: TString30;
    i: byte;
  begin
    i := pos(']', arg.stringValue);
    if i=0 then msg(EMsgFatal, C_STR_UNRECOGNIZABLE_ARGUMENT, arg.stringValue);
    token := copy(arg.stringValue, 2, i-2);
    success := any2int(token, arg.intValue);
    if not success then msg(EMsgFatal, C_STR_UNRECOGNIZABLE_ARGUMENT, arg.stringValue);
  end;

  procedure TCodeParser.parseRegister(var arg: TSentenceArgument);
  var 
    success: boolean;
    code, bitSize: byte;
  begin
    success := getRegisterInfoByName(arg.stringValue, code, bitSize);
    if not success then msg(EMsgFatal, C_STR_UNRECOGNIZABLE_ARGUMENT, arg.stringValue);
    arg.registerCode := code;
  end;

  procedure TCodeParser.parsePointer(var arg: TSentenceArgument);
  var 
    param, token: TString30;
    i, j: byte;
    constantValue: TUInt32;
    code, bitSize: byte;
    success: boolean;
  begin
    param := arg.stringValue;
    i := pos('+', param);
    if i = 0 then i := pos('-', param);
    if i = 0 then i := pos(']', param);

    { extract the register part }
    j := pos('[', param) + 1;
    while param[j]=' ' do inc(j);      
    token := copy(param, j, i-j);
    success := getRegisterInfoByName(token, code, bitSize);
    if not success then msg(EMsgFatal, C_STR_UNRECOGNIZABLE_ARGUMENT, token);
    arg.registerCode := code;

    { extract the constant value part }
    if param[i] = ']' then
      arg.offset := 0
    else begin
      j := pos(']', param);
      token := copy(param, i+1, j-i-1);
      success := any2int(token, constantValue);
      if not success then msg(EMsgFatal, C_STR_INVALID_POINTER_CONSTANT, token);
      if param[i] = '-' then constantValue := -constantValue;
      if (constantValue<-32768) or (constantValue>32767) then 
        msg(EMsgFatal, C_STR_INVALID_POINTER_CONSTANT_RANGE, '');
      arg.offset := constantValue;
    end;
  end;

  { Other }

end.
