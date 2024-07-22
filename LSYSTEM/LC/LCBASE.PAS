{
  Types, constants and utility functions used by the compiler
}
unit
  lcbase;

interface

  uses
    ascii,
    lcommon,
    lliteral,
    utils,
    uobject;

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
      argType: EParameterType;  { what kind of argument this is }
      stringValue: TString30;   { the argument as was extracted from the source code }
      intValue: TUInt32;        { if it's a literal or a memory address, this is it }
      registerCode: byte;       { if it's a pointer or a register this is its register code }
      offset: TInt16;           { if it's a pointer this is its offset constant }
    end;

    TSentence = record
      labelName: TString30;
      opname: TString30;
      opcode: byte;
      args: array[0..1] of TSentenceArgument;
    end;

    PSymbol = ^TSymbol;
    TSymbol = object (TObject)
      name: TString30;
      value: TUInt32;
    end;

  const
    C_REGISTER_INFO: TRegisterInfoArray = (
      (name: 'sp';  code:C_SP;  bitSize:32),
      (name: 'bp';  code:C_BP;  bitSize:32),
      (name: 'ip';  code:C_IP;  bitSize:32),
      (name: 'cc';  code:C_CC;  bitSize:32),
      (name: 'eax'; code:C_EAX; bitSize:32),
      (name: 'ax';  code:C_AX;  bitSize:16),
      (name: 'ah';  code:C_AH;  bitSize:8),
      (name: 'al';  code:C_AL;  bitSize:8),
      (name: 'ebx'; code:C_EBX; bitSize:32),
      (name: 'bx';  code:C_BX;  bitSize:16),
      (name: 'bh';  code:C_BH;  bitSize:8),
      (name: 'bl';  code:C_BL;  bitSize:8),
      (name: 'ecx'; code:C_ECX; bitSize:32),
      (name: 'cx';  code:C_CX;  bitSize:16),
      (name: 'ch';  code:C_CH;  bitSize:8),
      (name: 'cl';  code:C_CL;  bitSize:8),
      (name: 'edx'; code:C_EDX; bitSize:32),
      (name: 'dx';  code:C_DX;  bitSize:16),
      (name: 'dh';  code:C_DH;  bitSize:8),
      (name: 'dl';  code:C_DL;  bitSize:8),
      (name: 'cs';  code:C_CS;  bitSize:32),
      (name: 'ds';  code:C_DS;  bitSize:32),
      (name: 'ss';  code:C_SS;  bitSize:32)
    );


    C_OPCODE_INFO: TOpcodeInfoArray = (
      (name: 'mov'; code:C_MOV; count:2),
      (name: 'add'; code:C_ADD; count:2),
      (name: 'sub'; code:C_SUB; count:2),
      (name: 'mul'; code:C_MUL; count:2),
      (name: 'div'; code:C_DIV; count:2),
      (name: 'mod'; code:C_MOD; count:2),
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
      (name: 'jerr'; code:C_JERR; count:1),

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
      getParameterType := EParameterTypeSymbol;    
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
      EParameterTypeSymbol: result := 8;
      EParameterTypeAddress, EParameterTypePointer: result := 32;
    else
      result := 0;
    end;
    getBitSize := result;
  end;

end.