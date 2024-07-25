{
  this unit implements the flow control operations of the instruction set
}
unit 
  op_flow;

interface

  uses
    op_base, lcommon;

  procedure _jmp(const c: TContext); far;
  procedure _je(const c: TContext); far;
  procedure _jg(const c: TContext); far;
  procedure _jl(const c: TContext); far;
  procedure _jz(const c: TContext); far;
  procedure _jp(const c: TContext); far;
  procedure _jn(const c: TContext); far;
  procedure _jnz(const c: TContext); far;
  procedure _jerr(const c: TContext); far;
  procedure _call(const c: TContext); far;
  procedure _ret(const c: TContext); far;

implementation

  procedure _jmp(const c: TContext);
  begin
    c.regs^.IP := c.regs^.CS + getParamValue(c, c.paramType0, c.instruction.param0);
  end;

  procedure _je(const c: TContext);
  var
    address, value: TUInt32;
  begin
    value := getParamValue(c, c.paramType0, c.instruction.param0);
    address := c.regs^.CS + getParamValue(c, c.paramType1, c.instruction.param1);
    if value = c.regs^.EAX then
      c.regs^.IP := address
    else
      inc(c.regs^.IP, sizeOf(TInstruction));
  end;

  procedure _jg(const c: TContext);
  var
    address, value: TUInt32;
  begin
    value := getParamValue(c, c.paramType0, c.instruction.param0);
    address := c.regs^.CS + getParamValue(c, c.paramType1, c.instruction.param1);
    if value > c.regs^.EAX then
      c.regs^.IP := address
    else
      inc(c.regs^.IP, sizeOf(TInstruction));
  end;

  procedure _jl(const c: TContext);
  var
    address, value: TUInt32;
  begin
    value := getParamValue(c, c.paramType0, c.instruction.param0);
    address := c.regs^.CS + getParamValue(c, c.paramType1, c.instruction.param1);
    if value < c.regs^.EAX then
      c.regs^.IP := address
    else
      inc(c.regs^.IP, sizeOf(TInstruction));
  end;

  procedure _jz(const c: TContext);
  begin
    if (c.regs^.CC and C_CC_ZERO) = 1 then
      c.regs^.IP := c.regs^.CS + getParamValue(c, c.paramType0, c.instruction.param0)
    else
      inc(c.regs^.IP, sizeOf(TInstruction));
  end;

  procedure _jp(const c: TContext);
  begin
    if (c.regs^.CC and C_CC_SIGN) = 0 then
      c.regs^.IP := c.regs^.CS + getParamValue(c, c.paramType0, c.instruction.param0)
    else
      inc(c.regs^.IP, sizeOf(TInstruction));
  end;

  procedure _jn(const c: TContext);
  begin
    if (c.regs^.CC and C_CC_SIGN) = 1 then
      c.regs^.IP := c.regs^.CS + getParamValue(c, c.paramType0, c.instruction.param0)
    else
      inc(c.regs^.IP, sizeOf(TInstruction));
  end;

  procedure _jnz(const c: TContext);
  begin
    if (c.regs^.CC and C_CC_ZERO) = 0 then
      c.regs^.IP := c.regs^.CS + getParamValue(c, c.paramType0, c.instruction.param0)
    else
      inc(c.regs^.IP, sizeOf(TInstruction));
  end;

  procedure _jerr(const c: TContext);
  begin
    if (c.regs^.CC and C_CC_ERR) <> 0 then
    begin
      c.regs^.IP := c.regs^.CS + getParamValue(c, c.paramType0, c.instruction.param0);
      c.regs^.CC := c.regs^.CC and not C_CC_ERR;
    end else
      inc(c.regs^.IP, sizeOf(TInstruction));
  end;

  procedure _call(const c: TContext);
  var
    returnAddress, funcAddress: TUInt32;
  begin
    returnAddress := c.regs^.IP + sizeOf(TInstruction);
    funcAddress := c.regs^.CS + getParamValue(c, c.paramType0, c.instruction.param0);
    c.ram^.setValue(c.regs^.SS + c.regs^.SP, returnAddress);
    inc(c.regs^.SP, sizeOf(TUInt32));
    c.regs^.IP := funcAddress;
  end;

  procedure _ret(const c: TContext);
  var
    returnAddress: TUInt32;
  begin
    dec(c.regs^.SP, sizeOf(TUInt32));
    returnAddress := c.ram^.getValue(c.regs^.SS + c.regs^.SP);
    c.regs^.IP := returnAddress;
  end;

end.