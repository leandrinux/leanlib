{
  this unit implements the input/output operations of the instruction set
}
unit
  op_io;

interface

  uses
    op_base,
    lcommon,
    lrbase;

  procedure _out(const c: TContext); far;

implementation

  procedure _out(const c: TContext);
  begin
    writeln('out not implemented');
    setRegisterValue(c.regs, C_IP, getRegisterValue(c.regs, C_IP) + sizeOf(TInstruction));
  end;

end.