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
    C_SPACE = ' ';
    C_CR    = #13;
    C_LF    = #10;
    C_TAB   = #09;

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
      EParameterTypePointer,
      EParameterTypeSymbol
    );

    TParameterInfo = record
      paramType: EParameterType;
      bitSize: byte;
      value: TUInt32;
    end;

    TSentenceArgument = record
      stringValue: TString30;
      argType: EParameterType;
      offset: TInt16;
    end;

    TSentence = record
      labelName: TString30;
      opname: TString30;
      opcode: byte;
      args: array[0..1] of TSentenceArgument;
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
      (name: 'in'; code:C_IN; count:1)
    );  

  function getOpcodeInfoByName(const name: TInstructionName; var code, count: byte): boolean;
  function getRegisterInfoByName(const name:TRegisterName; var code, bitSize: byte): boolean;
  function getParameterType(const token: string): EParameterType;
  function getBitSize(const param: string; paramType:EParameterType): byte;

implementation

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

  function isValidRegister(const token: string): boolean;
  var
    i: byte;
  begin
    i := 0;
    while (i<C_REGISTER_COUNT) and (C_REGISTER_INFO[i].name<>token) do inc(i);
    isValidRegister := i<C_REGISTER_COUNT;
  end;

  function isValidSymbol(const token: string): boolean;
  const
    C_VALID_TOKEN_CHARS = ['A'..'Z','a'..'z','_'];
  var
    i: byte;
  begin
    i := 1;
    while (i<=length(token)) and (token[i] in C_VALID_TOKEN_CHARS) do inc(i);
    isValidSymbol := i>length(token);
  end;

  function getParameterType(const token: string): EParameterType;
  const
    C_SET_LITERALS: set of char = ['+', '-', '0'..'9', '$', '#', ''''];
  var 
    reg: string[3];
    i, j: byte;
  begin
    (*
      literals = 0, 1, 2, -23, $7, 0xAA, $A000, 0oAA, 0b0010, #77, 'a', 7.8, -4.3
      registers = eax, ax, fx, cc, ah, bl
      address = [$A000], [0xA48A]
      pointer = [AX+2], [EDX-5], [DS]
    *)
    getParameterType := EParameterTypeUnknown;
    if length(token)<1 then exit;
    if token[1] in C_SET_LITERALS then
      getParameterType := EParameterTypeLiteral
    else if token[1] = '[' then
    begin
      if length(token)<3 then exit;
      if token[2] in C_SET_LITERALS then
        getParameterType := EParameterTypeAddress
      else begin
        i := pos('+', token);
        if i=0 then i := pos('-', token);
        j := pos(']', token);
        if i=0 then
          reg := copy(token, 2, length(token)-2)
        else
          reg := copy(token, 2, i-2);
        if isValidRegister(reg) and (j<>0) and (j>i) then 
          getParameterType := EParameterTypePointer
        else if isValidSymbol(token) then
          getParameterType := EParameterTypeSymbol;
      end;
    end else if isValidRegister(token) then
      getParameterType := EParameterTypeRegister
    else
      getParameterType := EParameterTypeSymbol
;    
  end;

  function getLiteralBitSize(const param: string): byte;
  var
    value: TUInt32;
    result: byte;
  begin
    result := 0;
    if not any2int(param, value) then 
    begin
      writeln('literal argument "', param, '" could not be recognized');
      exit;
    end;
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
    begin
      writeln ('register argument could not be recognized');
      exit;
    end;
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

end.