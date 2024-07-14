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
    end;

  function getPointerValue(regs: PRegisters; ram: PRAM; param: TUInt32): TUInt32;
  procedure setPointerValue(regs: PRegisters; ram: PRAM; param, value: TUInt32);

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

end.