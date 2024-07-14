{
  Implements the CPU instruction set
}
unit
  linstset;

interface

  uses
    lcommon, lrbase;

(*
mov 1
out 81
sub 3
jnz 40
jmp 33
*)
  procedure exec(const c: TContext);

implementation

  type
    TInstructionHandler = procedure(const c: TContext);
    THandlerVector = array [byte] of TInstructionHandler;

  var
    handlerVector: THandlerVector;

  procedure mov(const c: TContext); far;
  begin
  end;

  procedure registerOpcodes;
  begin
    fillchar(handlerVector, sizeof(handlerVector), 0);
    handlerVector[C_MOV] := mov;
  end;

  procedure exec(const c: TContext);
  begin
    writeln('opcode: ', c.instruction.header.opcode);
  end;

begin
  registerOpcodes;
end.