{
  Implements the CPU instruction set
}
unit
  linstset;

interface

  uses
    lcommon, lrbase;

  procedure exec(const c: TContext);

implementation

  type
    TInstructionHandler = procedure(const c: TContext);
    THandlerVector = array [byte] of TInstructionHandler;

  var
    handlerVector: THandlerVector;

  procedure _mov(const c: TContext); far;
  begin
    writeln('mov');
  end;

  procedure _out(const c: TContext); far;
  begin
    writeln('out');
  end;

  procedure _sub(const c: TContext); far;
  begin
    writeln('sub');
  end;

  procedure _jnz(const c: TContext); far;
  begin
    writeln('jnz');
  end;

  procedure _jmp(const c: TContext); far;
  begin
    writeln('jmp');
  end;

  procedure registerOpcodes;
  begin
    fillchar(handlerVector, sizeof(handlerVector), 0);
    handlerVector[C_MOV] := _mov;
    handlerVector[C_OUT] := _out;
    handlerVector[C_SUB] := _sub;
    handlerVector[C_JNZ] := _jnz;
    handlerVector[C_JMP] := _jmp;
  end;

  procedure exec(const c: TContext);
  begin
    handlerVector[c.instruction.header.opcode](c);
  end;

begin
  registerOpcodes;
end.