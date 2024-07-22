{
  Basic types and procedures needed to implement the instruction set
}
unit
  op_base;

interface

  uses
    lcommon, lregs, lram, lbus;

  type
    TContext = record
      instruction: TInstruction;
      paramType0, paramType1: byte;
      regs: PRegisters;
      ram: PRAM;
      bus: PBus;
      stackSize: TUInt32;
    end;

  function getPointerValue(regs: PRegisters; ram: PRAM; param: TUInt32): TUInt32;
  procedure setPointerValue(regs: PRegisters; ram: PRAM; param, value: TUInt32);
  procedure cpuError(regs: PRegisters; code: TUInt32);
  function getRegisterBitSize(const param: TUInt32): byte;

implementation

  function getPointerValue(regs: PRegisters; ram: PRAM; param: TUInt32): TUInt32;
  var
    address: TUInt32;
  begin
    address := getRegisterValue(regs, param and $000000FF) + (param shr 16);
    getPointerValue := ram^.getValue(address);
  end;

  procedure setPointerValue(regs: PRegisters; ram: PRAM; param, value: TUInt32);
  var
    address: TUInt32;
  begin
    address := getRegisterValue(regs, param and $000000FF) + (param shr 16);
    ram^.setValue(address, value);
  end;

  procedure cpuError(regs: PRegisters; code: TUInt32);
  begin
    with regs^ do
    begin
      CC := CC OR C_CC_ERR;
      EAX := code;
      EBX := IP;
      IP := 0;
    end;
  end;

  function getRegisterBitSize(const param: TUInt32): byte;
  begin
    case param of
      C_AH, C_BH, C_CH, C_DH, C_AL, C_BL, C_CL, C_DL: 
        getRegisterBitSize := 8;

      C_AX, C_BX, C_CX, C_DX: 
        getRegisterBitSize := 16;
    else
      getRegisterBitSize := 32;
    end;       
  end;

end.