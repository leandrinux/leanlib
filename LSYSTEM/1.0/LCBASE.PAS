{
  Types, constants and utility functions used by the compiler
}
unit
  lcbase;

interface

  uses
    lcommon,
    lliteral,
    utils;

  const
    C_LASMC_VERSION = '0.1';
    C_READ_BUFFER_SIZE = 1024;
    C_STATE_STACK_SIZE = 4;
    C_SPACE = ' ';
    C_CR    = #13;
    C_LF    = #10;
    C_TAB   = #09;
    C_SPACING_CHARS = [C_SPACE, C_TAB, C_LF, C_CR];
    C_MOV = $01; C_ADD = $02; C_SUB = $03; C_MUL = $04;
    C_DIV = $05; C_CMP = $06; C_SHL = $07; C_SHR = $08;
    C_FADD = $09; C_FSUB = $0A; C_FMUL = $0B; C_FDIV = $0C;
    C_JMP = $21; C_JE = $22; C_JG = $23; C_JL = $24;
    C_JZ = $25; C_JP = $26; C_JN = $27; C_JNZ = $28;
    C_AND = $31; C_OR = $32; C_NOT = $33; C_XOR = $34;
    C_PUSH = $41; C_POP = $42; C_PUSHA = $43; C_POPA = $44;
    C_CALL = $45; C_RET = $46; C_OUT = $51; C_IN = $52;

  type
    TRegisterName = string[3];

    TRegisterInfo = record
      name: TRegisterName;
      code: TUInt8;
      bitSize: TUInt8;
    end;

    TRegisterInfoArray = array[0..C_REGISTER_COUNT-1] of TRegisterInfo;

    TInstructionName = string[5];

    TParamCount = 0..2;

    TOpcodeInfo = record
      name: TInstructionName;
      code: TUInt8;
      count: TParamCount;
    end;

    TOpcodeInfoArray = array[0..C_OPCODE_COUNT-1] of TOpcodeInfo;

    EParameterType = (
      EParameterTypeUnknown,
      EParameterTypeLiteral,
      EParameterTypeRegister,
      EParameterTypeAddress,
      EParameterTypePointer
    );

    TParameterInfo = record
      paramType: EParameterType;
      bitSize: byte;
      value: TUInt32;
    end;

    TFileBuffer = record
      data: array[0..C_READ_BUFFER_SIZE-1] of char; { data in buffer }
      size: word;                                   { how many bytes of valid data in buffer }
      position: word;                               { current position within buffer }
    end;

    EState = (                          { code parsing states}
      EStateStart,                      { parsing starts here }
      EStateEnd,                        { parsing ends here }
      EStateSkipSpacesAndLineBreaks,    { skipping empty spaces and line breaks }
      EStateSkipSpaces,                 { skipping spaces only }
      EStateReadInstruction,            { reading instruction name }
      EStateReadParam0,                 { reading first parameter }
      EStateReadParam1,                 { reading second parameter }
      EStateBuildBinaryInstruction,     { builds binary code based on collected instruction data }
      EStateCommentUntilLineBreak,      { skipping everything until the next line break }
      EStateCommentUntilDelimiter       { skipping everything until a comment block ending tag is found }
    );

    TStateStack = record
      values: array [0..C_STATE_STACK_SIZE-1] of EState;
      count: word;
      state: EState;
    end;

    TInstructionData = record
      name: TInstructionName;           { the name of the instruction as written in code }
      param0: string;                   { the first parameter as written in code }
      param1: string;                   { the second parameter as written in code }
      paramType0: EParameterType;       { type of the first parameter }
      paramType1: EParameterType;       { type of the second parameter }
      paramValue0: TUInt32;             { binary value for first parameter }
      paramValue1: TUInt32;             { binary value for second parameter }
      opcode: byte;                     { the operation code that matches the specified instruction }
      expectedParamCount: byte;         { how many arguments this instruction requires }
    end;

    TBuild = record
      sourceFileName: string;           { name of the file being compiled }
      sourceFile: file;                 { source file handle }
      isOpen: boolean;                  { indicates if file is open correctly }
      ch: char;                         { the character being currently examined }
      lineNumber: longint;              { current line number }
      lineCharacter: word;              { char number being evaluated in current line }
      instructionCount: longint;        { how many instructions have been built }
      fileBuffer: TFileBuffer;          { data buffer used to read file }
      stack: TStateStack;               { stack of machine states }
      instructionData: TInstructionData { the instruction and arguments retrieved from the line }
    end;

  const
    C_REGISTER_INFO: TRegisterInfoArray = (
      (name: 'sp'; code:$10; bitSize:32),
      (name: 'bp'; code:$20; bitSize:32),
      (name: 'ip'; code:$30; bitSize:32),
      (name: 'cc'; code:$40; bitSize:32),
      (name: 'eax'; code:$50; bitSize:32),
      (name: 'ax'; code:$51; bitSize:16),
      (name: 'ah'; code:$52; bitSize:8),
      (name: 'al'; code:$53; bitSize:8),
      (name: 'ebx'; code:$60; bitSize:32),
      (name: 'bx'; code:$61; bitSize:16),
      (name: 'bh'; code:$62; bitSize:8),
      (name: 'bl'; code:$63; bitSize:8),
      (name: 'ecx'; code:$70; bitSize:32),
      (name: 'cx'; code:$71; bitSize:16),
      (name: 'ch'; code:$72; bitSize:8),
      (name: 'cl'; code:$73; bitSize:8),
      (name: 'edx'; code:$80; bitSize:32),
      (name: 'dx'; code:$81; bitSize:16),
      (name: 'dh'; code:$82; bitSize:8),
      (name: 'dl'; code:$83; bitSize:8),
      (name: 'cs'; code:$A0; bitSize:32),
      (name: 'ds'; code:$A1; bitSize:32),
      (name: 'ss'; code:$A2; bitSize:32)
    );


    C_OPCODE_INFO: TOpcodeInfoArray = (
      (name: 'mov'; code:C_MOV; count:2),
      (name: 'add'; code:C_ADD; count:2),
      (name: 'sub'; code:C_SUB; count:2),
      (name: 'mul'; code:C_MUL; count:2),
      (name: 'div'; code:C_DIV; count:2),
      (name: 'cmp'; code:C_CMP; count:2),
      (name: 'shl'; code:C_SHL; count:2),
      (name: 'shr'; code:C_SHR; count:2),
      (name: 'fadd'; code:C_FADD; count:2),
      (name: 'fsub'; code:C_FSUB; count:2),
      (name: 'fmul'; code:C_FMUL; count:2),
      (name: 'fdiv'; code:C_FDIV; count:2),

      (name: 'jmp'; code:C_JMP; count:1),
      (name: 'je'; code:C_JE; count:2),
      (name: 'jg'; code:C_JG; count:2),
      (name: 'jl'; code:C_JL; count:2),
      (name: 'jz'; code:C_JZ; count:1),
      (name: 'jp'; code:C_JP; count:1),
      (name: 'jn'; code:C_JN; count:1),
      (name: 'jnz'; code:C_JNZ; count:1),

      (name: 'and'; code:C_AND; count:2),
      (name: 'or'; code:C_OR; count:2),
      (name: 'not'; code:C_NOT; count:1),
      (name: 'xor'; code:C_XOR; count:2),

      (name: 'push'; code:C_PUSH; count:1),
      (name: 'pop'; code:C_POP; count:1),
      (name: 'pusha'; code:C_PUSHA; count:0),
      (name: 'popa'; code:C_POPA; count:0),
      (name: 'call'; code:C_CALL; count:1),
      (name: 'ret'; code:C_RET; count:0),

      (name: 'out'; code:C_OUT; count:2),
      (name: 'in'; code:C_IN; count:2)
    );  

  var
    build: TBuild;

  procedure initBuild(const filename: string);
  function readChar: char;
  procedure raise(const msg: string);
  procedure message(const msg: string);
  procedure pushState(var stack: TStateStack; value: EState);
  procedure popState(var stack: TStateStack);
  function getOpcodeInfoByName(const name: TInstructionName; var code, count: byte): boolean;
  function getRegisterInfoByName(const name:TRegisterName; var code, bitSize: byte): boolean;
  function guessParameterType(const token: string): EParameterType;
  procedure validateParams;

implementation

  procedure initBuild(const filename: string);
  begin
    with build do
    begin
      sourceFileName := filename;
      instructionCount := 0;
      lineNumber := 1;
      lineCharacter := 1;
      fillChar(fileBuffer, sizeof(TFileBuffer), 0);
      stack.count := 0;
      stack.state := EStateStart;
      fileBuffer.position := 0;
      fileBuffer.size := 0;
      instructionData.name := '';
      instructionData.param0 := '';
      instructionData.param1 := '';
    end;
  end;

  function loadBuffer: boolean;
  begin
    loadBuffer := false;
    with build, fileBuffer do
    begin
      if eof(sourceFile) then exit;
      blockread(sourceFile, data, C_READ_BUFFER_SIZE, size);
      position := 0;
      loadBuffer := true;
    end;
  end;

  function readChar: char;
  begin
    readChar := #0;
    with build, fileBuffer do
    begin
      if (position = size) and not loadBuffer then exit;
      if size = 0 then exit;
      readChar := data[position];
      inc(position);
      inc(lineCharacter);
    end;
  end;
  
  procedure raise(const msg: string);
  begin
    with build do
    begin
      write('[X] Error: ', msg);
      if isOpen then
        writeln(' at line ', lineNumber,', position ', lineCharacter)
      else
        writeln;
      halt(1);
    end;
  end;

  procedure message(const msg: string);
  begin
    writeln('[-] ', msg);
  end;

  procedure pushState(var stack: TStateStack; value: EState);
  begin
    with stack do
      if stack.count = C_STATE_STACK_SIZE then
        raise('State stack overflow')
      else begin
        stack.values[stack.count] := value;
        count := count + 1;
      end;
  end;

  procedure popState(var stack: TStateStack);
  begin
    with stack do
      if count = 0 then
        raise('State stack empty')
      else begin
        count := count - 1;
        state := values[count];
      end;  
  end;

  function getOpcodeInfoByName(const name: TInstructionName; var code, count: byte): boolean;
  var
    i: byte;
  begin
    getOpcodeInfoByName := false;
    i := 0;
    while (i<C_OPCODE_COUNT) and (C_OPCODE_INFO[i].name <> name) do inc(i);
    if C_OPCODE_INFO[i].name <> name then exit;
    code := C_OPCODE_INFO[i].code;
    count := C_OPCODE_INFO[i].count;
    getOpcodeInfoByName := true;
  end;

  function getRegisterInfoByName(const name:TRegisterName; var code, bitSize: byte): boolean;
  var
    i: byte;
  begin
    getRegisterInfoByName := false;
    i := 0;
    while (i<C_REGISTER_COUNT) and (C_REGISTER_INFO[i].name <> name) do inc(i);
    if C_REGISTER_INFO[i].name <> name then exit;
    code := C_REGISTER_INFO[i].code;
    bitSize := C_REGISTER_INFO[i].bitSize;
    getRegisterInfoByName := true;
  end;

  function guessParameterType(const token: string): EParameterType;
  const
    C_SET_LITERALS: set of char = ['+', '-', '0'..'9', '$', '#', ''''];
    C_SET_REGISTERS: set of char = ['a', 'b', 'c', 'd', 'e', 'i', 's'];
  begin
    (*
      literals = 0, 1, 2, -23, $7, 0xAA, $A000, 0oAA, 0b0010, #77, 'a', 7.8, -4.3
      registers = eax, ax, fx, cc, ah, bl
      address = [$A000], [0xA48A]
      pointer = [AX]+2, [EDX]-5, [DS]
    *)
    guessParameterType := EParameterTypeUnknown;
    if length(token)<1 then exit;
    if token[1] in C_SET_LITERALS then
      guessParameterType := EParameterTypeLiteral
    else if token[1] in C_SET_REGISTERS then
      guessParameterType := EParameterTypeRegister
    else if token[1] = '[' then
    begin
      if length(token)<3 then exit;
      if token[2] in C_SET_LITERALS then
        guessParameterType := EParameterTypeAddress
      else if token[2] in C_SET_REGISTERS then 
        guessParameterType := EParameterTypePointer;
    end;    
  end;

  function getLiteralBitSize(const param: string): byte;
  var
    value: TUInt32;
    result: byte;
  begin
    result := 0;
    if not any2int(param, value) then 
      raise ('literal argument could not be recognized');
    if (value and $FFFF0000) <> 0 then 
      result := 32
    else if (value and $FF00) <> 0 then 
      result := 16
    else 
      result := 8;
    getLiteralBitSize := result;
  end;

  function getRegisterBitSize(const param: string): byte;
  var
    code, bitSize: byte;
  begin
    if not getRegisterInfoByName(param, code, bitSize) then
      raise ('register argument could not be recognized');
    getRegisterBitSize := bitSize;
  end;

  function getBitSize(const param: string; paramType:EParameterType): byte;
  var
    result: byte;
  begin
    case paramType of 
      EParameterTypeLiteral: result := getLiteralBitSize(param);
      EParameterTypeRegister: result := getRegisterBitSize(param);
      EParameterTypeAddress, EParameterTypePointer: result := 32;
    else
      result := 0;
    end;
    getBitSize := result;
  end;

  procedure validateParams;
  const 
    { these instructions do not support a literal as first parameter }
    C_OPCODES_NO_FIRST_LITERAL: set of byte = 
      [C_MOV, C_ADD, C_SUB, C_MUL, C_DIV, C_SHL, C_SHR, 
       C_FADD, C_FSUB, C_FMUL, C_FDIV, C_AND, C_OR, C_NOT, 
       C_XOR, C_JMP, C_JZ, C_JP, C_JN, C_JNZ, C_CALL];

    { these instructions do not support a literal as second parameter }
    C_OPCODES_NO_SECOND_LITERAL: set of byte = 
      [C_JE, C_JG, C_JL];

    { these instructions cannot have a register in the first parameter and a
      literal on the second, where the register has a smaller bitsize than the literal }
    C_OPCODES_LITERAL_BITSIZE_CHK: set of byte =
      [ C_MOV, C_ADD, C_SUB, C_MUL, C_DIV, 
        C_FADD, C_FSUB, C_FMUL, C_FDIV, C_AND, 
        C_OR, C_NOT, C_XOR ];

  var 
    paramCount: byte;
  begin
    with build.instructionData do
    begin
      paramCount := 0;

      { check the number of given parameters }
      if length(param0)>0 then inc(paramCount);
      if length(param1)>0 then inc(paramCount);
      if paramCount<>expectedParamCount then
        raise('instruction ' + name + 
          ' expects ' + intToStr(expectedParamCount) + 
          ' parameters, but it got ' + intToStr(paramCount)
        );
        
      { check the parameter types are correct }
      paramType0 := guessParameterType(param0);
      paramType1 := guessParameterType(param1);

      if (opcode in C_OPCODES_NO_FIRST_LITERAL) and (paramType0 = EParameterTypeLiteral) then
        raise('instruction ' + name + ' does not support a literal as first parameter');

      if (opcode in C_OPCODES_NO_SECOND_LITERAL) and (paramType1 = EParameterTypeLiteral) then
        raise('instruction ' + name + ' does not support a literal as second parameter');

      { check that the left size bit size is equal or greater than the right size bit size }
      if (paramType0 = EParameterTypeRegister) 
         and (paramType1 in [EParameterTypeLiteral, EParameterTypeRegister]) 
         and (opcode in C_OPCODES_LITERAL_BITSIZE_CHK) 
         and (getBitSize(param0, paramType0) < getBitSize(param1, paramType1)) then
        raise('register in first parameter cannot fit literal or register on the second parameter');

    end;
  end;

end.