{
  this unit implements the stack functions of the CPU
}
unit 
  op_stack;

interface

  uses
    op_base,
    lcommon,
    lregs;

  procedure _push(const c: TContext); far;
  procedure _pop(const c: TContext); far;
  procedure _pusha(const c: TContext);
  procedure _popa(const c: TContext); far;

implementation

  procedure _push(const c: TContext);
  var
    value, address: TUInt32; 
  begin
    if c.regs^.SP = c.stackSize then
    begin
      cpuError(c.regs, C_ERR_STACK_OVERFLOW);
      exit;
    end;
    value := getParamValue(c, c.paramType0, c.instruction.param0);
    address := c.regs^.SS + c.regs^.SP;
    setParamValue(c, C_PARAMETER_ADDRESS, address, value);
    inc(c.regs^.SP, sizeOf(TUInt32));        
    inc(c.regs^.IP, sizeOf(TInstruction));
  end;

  procedure _pop(const c: TContext);
  var
    address, value: TUInt32;
  begin
    if c.regs^.SP = 0 then
    begin
      cpuError(c.regs, C_ERR_STACK_EMPTY);
      exit;
    end;
    dec(c.regs^.SP, sizeOf(TUInt32));        
    address := c.regs^.SS + c.regs^.SP;
    value := getParamValue(c, C_PARAMETER_ADDRESS, address);
    inc(c.regs^.IP, sizeOf(TInstruction));
  end;

  procedure pushRegister(const c: TContext; value: TUInt32);
  begin
    if c.regs^.SP = c.stackSize then
    begin
      cpuError(c.regs, C_ERR_STACK_OVERFLOW);
      exit;
    end;
    c.ram^.setValue(c.regs^.SS + c.regs^.SP, value);
    inc(c.regs^.SP, sizeOf(TUInt32));
  end;    

  procedure _pusha(const c: TContext);
  begin
    pushRegister(c, C.regs^.EAX);
    pushRegister(c, C.regs^.EBX);
    pushRegister(c, C.regs^.ECX);
    pushRegister(c, C.regs^.EDX);
    inc(c.regs^.IP, sizeOf(TInstruction));
  end;

  function popRegister(const c: TContext; var value: TUInt32): boolean;
  begin
    if c.regs^.SP = 0 then
    begin
      cpuError(c.regs, C_ERR_STACK_EMPTY);
      popRegister := false
    end else begin
      dec(c.regs^.SP, sizeOf(TUInt32)); 
      value := c.ram^.getValue(c.regs^.SS + c.regs^.SP);
      popRegister := true;
    end;
  end;

  procedure _popa(const c: TContext);
  begin
    inc(c.regs^.IP, sizeOf(TInstruction));
    if not popRegister(c, c.regs^.EDX) then exit;
    if not popRegister(c, c.regs^.ECX) then exit;
    if not popRegister(c, c.regs^.EBX) then exit;
    popRegister(c, c.regs^.EAX);
  end;

end.