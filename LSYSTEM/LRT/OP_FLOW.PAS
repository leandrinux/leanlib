{
  this unit implements the flow control operations of the instruction set
}
unit 
  op_flow;

interface

  uses
    op_base,
    lcommon,
    lregs;

  procedure _jmp(const c: TContext); far;
  procedure _je(const c: TContext); far;
  procedure _jg(const c: TContext); far;
  procedure _jl(const c: TContext); far;
  procedure _jz(const c: TContext); far;
  procedure _jp(const c: TContext); far;
  procedure _jn(const c: TContext); far;
  procedure _jnz(const c: TContext); far;
  procedure _call(const c: TContext); far;
  procedure _ret(const c: TContext); far;

implementation

  procedure _jmp(const c: TContext);
  begin
    with c, instruction do case paramType0 of
      C_PARAMETER_LITERAL:
        c.regs^.IP := param0;
      C_PARAMETER_ADDRESS:
        c.regs^.IP := ram^.getValue(param0);
      C_PARAMETER_REGISTER:
        c.regs^.IP := getRegisterValue(regs, param0);
      C_PARAMETER_POINTER:
        c.regs^.IP := getPointerValue(regs, ram, param0);
    end;
  end;

  procedure _je(const c: TContext);
  var
    address, value: TUInt32;
  begin
    with c, instruction do
    begin
      case paramType0 of
        C_PARAMETER_LITERAL: value := param0;
        C_PARAMETER_ADDRESS: value := ram^.getValue(param0);
        C_PARAMETER_REGISTER: value := getRegisterValue(regs, param0);
        C_PARAMETER_POINTER: value := getPointerValue(regs, ram, param0);
      end;
      case paramType1 of
        C_PARAMETER_LITERAL: address := param1;
        C_PARAMETER_ADDRESS: address := ram^.getValue(param1);
        C_PARAMETER_REGISTER: address := getRegisterValue(regs, param1);
        C_PARAMETER_POINTER: address := getPointerValue(regs, ram, param1);
      end;
      if value = regs^.EAX then
        regs^.IP := address
      else
        inc(regs^.IP, sizeOf(TInstruction));
    end;
  end;

  procedure _jg(const c: TContext);
  var
    address, value: TUInt32;
  begin
    with c, instruction do
    begin
      case paramType0 of
        C_PARAMETER_LITERAL: value := param0;
        C_PARAMETER_ADDRESS: value := ram^.getValue(param0);
        C_PARAMETER_REGISTER: value := getRegisterValue(regs, param0);
        C_PARAMETER_POINTER: value := getPointerValue(regs, ram, param0);
      end;
      case paramType1 of
        C_PARAMETER_LITERAL: address := param1;
        C_PARAMETER_ADDRESS: address := ram^.getValue(param1);
        C_PARAMETER_REGISTER: address := getRegisterValue(regs, param1);
        C_PARAMETER_POINTER: address := getPointerValue(regs, ram, param1);
      end;
      if value > regs^.EAX then
        regs^.IP := address
      else
        inc(regs^.IP, sizeOf(TInstruction));
    end;
  end;

  procedure _jl(const c: TContext);
  var
    address, value: TUInt32;
  begin
    with c, instruction do
    begin
      case paramType0 of
        C_PARAMETER_LITERAL: value := param0;
        C_PARAMETER_ADDRESS: value := ram^.getValue(param0);
        C_PARAMETER_REGISTER: value := getRegisterValue(regs, param0);
        C_PARAMETER_POINTER: value := getPointerValue(regs, ram, param0);
      end;
      case paramType1 of
        C_PARAMETER_LITERAL: address := param1;
        C_PARAMETER_ADDRESS: address := ram^.getValue(param1);
        C_PARAMETER_REGISTER: address := getRegisterValue(regs, param1);
        C_PARAMETER_POINTER: address := getPointerValue(regs, ram, param1);
      end;
      if value < regs^.EAX then
        regs^.IP := address
      else
        inc(regs^.IP, sizeOf(TInstruction));
    end;
  end;

  procedure _jz(const c: TContext);
  begin
    if (c.regs^.CC and C_CC_ZERO) = 1 then
      c.regs^.IP := c.instruction.param0
    else
      inc(c.regs^.IP, sizeOf(TInstruction));
  end;

  procedure _jp(const c: TContext);
  begin
    if (c.regs^.CC and C_CC_SIGN) = 0 then
      c.regs^.IP := c.instruction.param0
    else
      inc(c.regs^.IP, sizeOf(TInstruction));
  end;

  procedure _jn(const c: TContext);
  begin
    if (c.regs^.CC and C_CC_SIGN) = 1 then
      c.regs^.IP := c.instruction.param0
    else
      inc(c.regs^.IP, sizeOf(TInstruction));
  end;

  procedure _jnz(const c: TContext);
  begin
    if (c.regs^.CC and C_CC_ZERO) = 0 then
      c.regs^.IP := c.instruction.param0
    else
      inc(c.regs^.IP, sizeOf(TInstruction));
  end;

  procedure _call(const c: TContext);
  var
    returnAddress, funcAddress: TUInt32;
  begin
    returnAddress := c.regs^.IP + sizeOf(TInstruction);
    with c, instruction do
    begin
      case paramType0 of
        C_PARAMETER_LITERAL: funcAddress := param0;
        C_PARAMETER_ADDRESS: funcAddress := ram^.getValue(param0);
        C_PARAMETER_REGISTER: funcAddress := getRegisterValue(regs, param0);
        C_PARAMETER_POINTER: funcAddress := getPointerValue(regs, ram, param0);
      end;
      ram^.setValue(c.regs^.SP, returnAddress);
    end;
    dec(c.regs^.SP, sizeOf(TUInt32));
    c.regs^.IP := funcAddress;
  end;

  procedure _ret(const c: TContext);
  var
    returnAddress: TUInt32;
  begin
    returnAddress := c.ram^.getValue(c.regs^.SP);
    inc(c.regs^.SP, sizeOf(TUInt32));
    c.regs^.IP := returnAddress;
  end;

end.