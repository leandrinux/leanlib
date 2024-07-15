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
    THandlers = array [byte] of TInstructionHandler;

  var
    handlers: THandlers;

  procedure exec(var c: TContext);
  begin
    with c.instruction.header do
    begin
      c.paramType0 := params shr 4;
      c.paramType1 := params and $0F;
    end;
    handlers[c.instruction.header.opcode](c);
  end;

  procedure registerOpcodes;
  begin
    fillchar(handlers, sizeof(handlers), 0);

    { math }
    handlers[C_MOV] := _mov;
    handlers[C_ADD] := _add;
    handlers[C_SUB] := _sub;
    handlers[C_MUL] := _mul;
    handlers[C_DIV] := _div;
    handlers[C_CMP] := _cmp;

    { flow }
    handlers[C_JMP] := _jmp;
    handlers[C_JE] := _je;
    handlers[C_JG] := _jg;
    handlers[C_JL] := _jl;
    handlers[C_JZ] := _jz;
    handlers[C_JP] := _jp;
    handlers[C_JN] := _jn;
    handlers[C_JNZ] := _jnz;

    { IO }
    handlers[C_OUT] := _out;
  end;

begin
  registerOpcodes;
end.