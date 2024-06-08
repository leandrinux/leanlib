{
  Types and constants used by the compiler
}
unit
  lcbase;

interface

  uses
    lcommon;

  type
    TRegisterName = TString3;

    TRegisterInfo = record
      name: TRegisterName;
      code: TUInt8;
      bitSize: TUInt8;
    end;

    TRegisterInfoArray = array[0..C_REGISTER_COUNT-1] of TRegisterInfo;

    TOpcodeName = TString5;

    TParamCount = 0..2;

    TOpcodeInfo = record
      name: TOpcodeName;
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
      (name: 'mov'; code:$01; count:2),
      (name: 'add'; code:$02; count:2),
      (name: 'sub'; code:$03; count:2),
      (name: 'mul'; code:$04; count:2),
      (name: 'div'; code:$05; count:2),
      (name: 'cmp'; code:$06; count:2),
      (name: 'shl'; code:$07; count:2),
      (name: 'shr'; code:$08; count:2),
      (name: 'fadd'; code:$09; count:2),
      (name: 'fsub'; code:$0A; count:2),
      (name: 'fmul'; code:$0B; count:2),
      (name: 'fdiv'; code:$0C; count:2),

      (name: 'jmp'; code:$21; count:1),
      (name: 'je'; code:$22; count:2),
      (name: 'jg'; code:$23; count:2),
      (name: 'jl'; code:$24; count:2),
      (name: 'jz'; code:$25; count:1),
      (name: 'jp'; code:$26; count:1),
      (name: 'jn'; code:$27; count:1),
      (name: 'jnz'; code:$28; count:1),

      (name: 'and'; code:$31; count:2),
      (name: 'or'; code:$32; count:2),
      (name: 'not'; code:$33; count:1),
      (name: 'xor'; code:$34; count:2),

      (name: 'push'; code:$41; count:1),
      (name: 'pop'; code:$42; count:1),
      (name: 'pusha'; code:$43; count:0),
      (name: 'popa'; code:$44; count:0),
      (name: 'call'; code:$45; count:1),
      (name: 'ret'; code:$46; count:0),

      (name: 'out'; code:$51; count:2),
      (name: 'in'; code:$52; count:2)
    );  

  function getOpcodeInfoByName(const name: TOpcodeName; var code, count: byte): boolean;
  function getRegisterInfoByName(const name:TRegisterName; var code, bitSize: byte): boolean;
  function guessParameterType(const token: string): EParameterType;

implementation

  function getOpcodeInfoByName(const name: TOpcodeName; var code, count: byte): boolean;
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
  
end.