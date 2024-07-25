{
  this unit implements the stack functions of the CPU
}
unit 
  op_stack;

interface

  uses
    op_base, lcommon;

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
    c.ram^.setValue(address, value);
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
    value := c.ram^.getValue(address);
    setParamValue(c, c.paramType0, c.instruction.param0, value);
    inc(c.regs^.IP, sizeOf(TInstruction));
  end;

  procedure _pusha(const c: TContext);

    function pushRegister(value: TUInt32): boolean;
    begin
      if c.regs^.SP = c.stackSize then
      begin
        cpuError(c.regs, C_ERR_STACK_OVERFLOW);
        pushRegister := false;
      end else
      begin
        c.ram^.setValue(c.regs^.SS + c.regs^.SP, value);
        inc(c.regs^.SP, sizeOf(TUInt32));
        pushRegister := true;
      end;
    end;    

  begin
    inc(c.regs^.IP, sizeOf(TInstruction));
    if not pushRegister(C.regs^.EAX) then exit;
    if not pushRegister(C.regs^.EBX) then exit;
    if not pushRegister(C.regs^.ECX) then exit;
    pushRegister(C.regs^.EDX);
  end;

  procedure _popa(const c: TContext);

    function popRegister(var value: TUInt32): boolean;
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

  begin
    inc(c.regs^.IP, sizeOf(TInstruction));
    if not popRegister(c.regs^.EDX) then exit;
    if not popRegister(c.regs^.ECX) then exit;
    if not popRegister(c.regs^.EBX) then exit;
    popRegister(c.regs^.EAX);
  end;

end.