{
  Types and constants needed by both the compiler and the vm
}
unit 
  lcommon;

interface

  const
    C_REGISTER_COUNT = 23;       { how many registers does the CPU have }
    C_OPCODE_COUNT   = 32;       { how many operations does the CPU recognize }
    
    C_MASK_FLAG_ZERO = $01;      { used to know if CC indicates a zero flag }
    C_MASK_FLAG_SIGN = $02;      { used to know the sign of the last operation that affected the CC }

    C_PARAMETER_LITERAL  = 0;    { param type value for literal parameters }
    C_PARAMETER_REGISTER = 1;    { param type value for register parameters }
    C_PARAMETER_ADDRESS  = 2;    { param type value for address parameters }
    C_PARAMETER_POINTER = 3;     { param type value for pointer parameters }

    C_BINARY_SIGNATURE : array[0..6] of char  = 'LSYSBIN';

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

    TInstructionHeader = packed record
      opcode: TUInt8;
      params: TUInt8;
    end;

    TInstruction = packed record
      header: TInstructionHeader;
      param0: TUInt32;
      param1: TUInt32;
    end;

  procedure message(const str: string);
  procedure error(const str: string);

implementation

  procedure message(const str: string);
  begin
    writeln('[-] ', str);
  end;

  procedure error(const str: string);
  begin
    writeln('[X] ', str);
    halt(1);
  end;

end.