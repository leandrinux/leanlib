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

  procedure _jnz(const c: TContext); far;
  procedure _jmp(const c: TContext); far;

implementation

  procedure _jnz(const c: TContext);
  begin
    if (c.regs^.CC and C_CC_ZERO) = 0 then
      setRegisterValue(c.regs, C_IP, c.instruction.param0)
    else
      setRegisterValue(c.regs, C_IP, getRegisterValue(c.regs, C_IP) + sizeOf(TInstruction));
  end;

  procedure _jmp(const c: TContext);
  begin
    with c, instruction do case paramType0 of
      C_PARAMETER_LITERAL:
        setRegisterValue(c.regs, C_IP, param0);
      C_PARAMETER_ADDRESS:
        setRegisterValue(c.regs, C_IP, ram^.getValue(param0));
      C_PARAMETER_REGISTER:
        setRegisterValue(c.regs, C_IP, getRegisterValue(regs, param0));
      C_PARAMETER_POINTER:
        setRegisterValue(c.regs, C_IP, getPointerValue(regs, ram, param0));
    end;
  end;

end.