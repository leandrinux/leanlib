{
  Types and constants needed by both the compiler and the vm
}
unit 
  lcommon;

interface

  const
    C_REGISTER_COUNT = 23;
    C_OPCODE_COUNT   = 32; 
    
    C_MASK_FLAG_ZERO = $01;
    C_MASK_FLAG_SIGN = $02;
    C_MASK_FLAG_IO   = $04;

    C_MASK_INST_PARAM0 = $0F;
    C_MASK_INST_PARAM1 = $F0;

    C_PARAM_LITERAL  = 0;
    C_PARAM_REGISTER = 1;
    C_PARAM_ADDRESS  = 2;
    C_PARAM_INDIRECT = 3;

    C_MASK_INDIRECT_OFFSET   = $00000000;
    C_MASK_INDIRECT_REGISTER = $0000000F;

  type
    TString3 = string[3];
    TString5 = string[5];
    TUInt8 = byte;
    TUInt16 = word;
    TUInt32 = longint;

    TInstruction = packed record
      header: TUInt32;
      param0: TUInt32;
      param1: TUInt32;
    end;

    TInstructionHeader = packed record
      opcode: TUInt16;
      params: TUInt16;
    end;

implementation

end.