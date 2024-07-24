{
  Types and constants needed by both the compiler and the vm
}
unit 
  lcommon;

interface

  uses
    crt, strings;

  const    
    C_STR_LSYSTEM_VERSION = '1.2';
    C_STR_LSYSTEM_CODENAME = 'Snowshoe';

    C_CC_ZERO = 1;  { used to know if CC indicates a zero flag }
    C_CC_SIGN = 2;  { used to know the sign of the last operation that affected the CC }
    C_CC_IO   = 4;  { used to know if an IO operation was successful }
    C_CC_ERR  = $80000000;  { used to know if there was a CPU error }

    C_ERR_DIVIDE_BY_ZERO    = 100;  { code used when divide by zero is attempted }
    C_ERR_STACK_OVERFLOW    = 101;  { code used when the stack is full and we push into it }
    C_ERR_STACK_EMPTY       = 102;  { code used when the stack is empty and we pop from it }
    C_ERR_INVALID_OPERATION = 103;  { code used when opcode or arguments are invalid }

    C_PARAMETER_LITERAL  = 0;    { param type value for literal parameters }
    C_PARAMETER_REGISTER = 1;    { param type value for register parameters }
    C_PARAMETER_ADDRESS  = 2;    { param type value for address parameters }
    C_PARAMETER_POINTER  = 3;    { param type value for pointer parameters }

    { opcodes } 
    C_OPCODE_COUNT   = 34;       { how many operations does the CPU recognize }
    C_MOV = $01; 
    C_ADD = $02; 
    C_SUB = $03; 
    C_MUL = $04;
    C_DIV = $05; 
    C_MOD = $0D;
    C_CMP = $06; 
    C_SHL = $07; 
    C_SHR = $08;
    C_FADD = $09; 
    C_FSUB = $0A; 
    C_FMUL = $0B; 
    C_FDIV = $0C;
    C_JMP = $21; 
    C_JE = $22; 
    C_JG = $23; 
    C_JL = $24;
    C_JZ = $25; 
    C_JP = $26; 
    C_JN = $27; 
    C_JNZ = $28;
    C_JERR = $29;
    C_AND = $31; 
    C_OR = $32; 
    C_NOT = $33; 
    C_XOR = $34;
    C_PUSH = $41; 
    C_POP = $42; 
    C_PUSHA = $43; 
    C_POPA = $44;
    C_CALL = $45; 
    C_RET = $46; 
    C_OUT = $51; 
    C_IN = $52;

    { registers }
    C_REGISTER_COUNT = 23;       { how many registers does the CPU have }
    C_SP = $10;
    C_BP = $20;
    C_IP = $30;
    C_CC = $40;
    C_EAX = $50;
    C_AX = $51;
    C_AH = $52;
    C_AL = $53;
    C_EBX = $60;
    C_BX = $61;
    C_BH = $62;
    C_BL = $63;
    C_ECX = $70;
    C_CX = $71;
    C_CH = $72;
    C_CL = $73;
    C_EDX = $80;
    C_DX = $81;
    C_DH = $82;
    C_DL = $83;
    C_CS = $A0;
    C_DS = $A1;
    C_SS = $A2;

  type
    TBinarySignature = array[0..6] of char;
  
  const
    C_BINARY_SIGNATURE : TBinarySignature  = 'LSYSBIN';

  type
    TString3 = string[3];
    TString5 = string[5];
    TString30 = string[30];
    TFloat32 = single;
    TUInt8 = byte;
    TUInt16 = word;
    TInt16 = integer;
    TUInt32 = longint;
    TChar = char;

    PUInt32 = ^TUInt32;

    TInstructionHeader = packed record
      opcode: TUInt8;
      params: TUInt8;
    end;

    PInstruction = ^TInstruction;
    TInstruction = packed record
      header: TInstructionHeader;
      param0: TUInt32;
      param1: TUInt32;
    end;

    EMsgKind = (
      EMsgNormal,
      EMsgFatal,
      EMsgVerbose,
      EMsgStrong,
      EMsgWarning,
      EMsgGood
    );

    PRegisters = ^TRegisters;
    TRegisters = record
      SP: TUInt32;
      BP: TUInt32;
      IP: TUInt32;
      CC: TUInt32;
      EAX: TUInt32;
      EBX: TUInt32;
      ECX: TUInt32;
      EDX: TUInt32;
      CS: TUInt32;
      DS: TUInt32;
      SS: TUInt32;    
    end;

  procedure msg(kind: EMsgKind; const str, args: string);

implementation

  procedure msg(kind: EMsgKind; const str, args: string);
  const
    C_MSG_COLORS: array [EMsgKind] of byte = (
      lightgray, lightred, darkgray, white, yellow, lightgreen
    );
  begin
    textColor(C_MSG_COLORS[kind]);
    case kind of
       EMsgNormal: write('[-] ');
        EMsgFatal: write('[X] ');
      EMsgVerbose: write('[ ] ');
      EMsgWarning: write('[!] ');
         EMsgGood: write(' *  ');
    end;
    writeln(strformatn(str, args));
    textColor(C_MSG_COLORS[EMsgNormal]);
    if kind = EMsgFatal then halt(1);
  end;

end.