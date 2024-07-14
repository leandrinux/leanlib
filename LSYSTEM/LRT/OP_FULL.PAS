{
  this unit brings together all the implementations for all the opcodes
  of the instruction set
}
unit
  op_full;

interface

  uses
    lcommon,
    op_base,
    op_math,
    op_flow,
    op_io;

  procedure exec(var c: TContext);

implementation

  type
    TInstructionHandler = procedure(const c: TContext);
    THandlerVector = array [byte] of TInstructionHandler;

  var
    handlerVector: THandlerVector;

  procedure exec(var c: TContext);
  begin
    with c.instruction.header do
    begin
      c.paramType0 := params shr 4;
      c.paramType1 := params and $0F;
    end;
    handlerVector[c.instruction.header.opcode](c);
  end;

  procedure registerOpcodes;
  begin
    fillchar(handlerVector, sizeof(handlerVector), 0);

    { math }
    handlerVector[C_MOV] := _mov;
    handlerVector[C_ADD] := _add;
    handlerVector[C_SUB] := _sub;

    { flow }
    handlerVector[C_JNZ] := _jnz;
    handlerVector[C_JMP] := _jmp;

    { IO }
    handlerVector[C_OUT] := _out;
  end;

begin
  registerOpcodes;
end.