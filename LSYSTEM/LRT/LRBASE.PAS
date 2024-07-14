{
  this unit contains elements that are exclusively
  shared by components of the runtime only
}
unit
  lrbase;

interface

  uses
    lcommon;

  const
    C_RAM_CMD_SEEK = 10;

  type
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

    TContext = record
      instruction: TInstruction;
      regs: PRegisters;
    end;


implementation

end.