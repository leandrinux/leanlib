{
  this unit implements the flow control operations of the instruction set
}
unit 
  op_flow;

interface

  uses
    op_base,
    lcommon,
    lrbase;

  procedure _jnz(const c: TContext); far;
  procedure _jmp(const c: TContext); far;

implementation

  procedure _jnz(const c: TContext);
  begin
    writeln('jnz not implemented');
  end;

  procedure _jmp(const c: TContext);
  begin
    writeln('jmp not implemented');
  end;

end.