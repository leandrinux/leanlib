{
  Implements the CPU instruction set
}
unit
  linstset;

interface

  uses
    lcommon, lrbase, lram;

  type
    TContext = record
      instruction: TInstruction;
      paramType0, paramType1: byte;
      regs: PRegisters;
      ram: PRAM;
    end;

  procedure exec(var c: TContext);

implementation

  type
    TInstructionHandler = procedure(const c: TContext);
    THandlerVector = array [byte] of TInstructionHandler;

  var
    handlerVector: THandlerVector;

  function getPointerValue(regs: PRegisters; ram: PRAM; param: TUInt32): TUInt32;
  var
    address: TUInt32;
  begin
    address := getRegisterValue(regs, param and $000000FF) + (param shr 16);
    getPointerValue := ram^.getValue(address);
  end;

  procedure setPointerValue(regs: PRegisters; ram: PRAM; param, value: TUInt32);
  var
    address: TUInt32;
  begin
    address := getRegisterValue(regs, param and $000000FF) + (param shr 16);
    ram^.setValue(address, value);
  end;

  procedure _mov(const c: TContext); far;
  begin
    writeln('mov');
    with c, instruction do case paramType0 of
      C_PARAMETER_ADDRESS:
        case paramType1 of
            C_PARAMETER_LITERAL: ram^.setValue(param0, param1);
            C_PARAMETER_ADDRESS: ram^.setValue(param0, ram^.getValue(param1));
            C_PARAMETER_REGISTER: ram^.setValue(param0, getRegisterValue(regs, param1));
            C_PARAMETER_POINTER: ram^.setValue(param0, getPointerValue(regs, ram, param1));
        end;
      C_PARAMETER_REGISTER:
        case paramType1 of
            C_PARAMETER_LITERAL: setRegisterValue(regs, param0, param1);
            C_PARAMETER_ADDRESS: setRegisterValue(regs, param0, ram^.getValue(param1));
            C_PARAMETER_REGISTER: setRegisterValue(regs, param0, getRegisterValue(regs, param1));
            C_PARAMETER_POINTER: setRegisterValue(regs, param0, getPointerValue(regs, ram, param1));
        end;
      C_PARAMETER_POINTER:
        case paramType1 of
            C_PARAMETER_LITERAL: setPointerValue(regs, ram, param0, param1);
            C_PARAMETER_ADDRESS: setPointerValue(regs, ram, param0, ram^.getValue(param1));
            C_PARAMETER_REGISTER: setPointerValue(regs, ram, param0, getRegisterValue(regs, param1));
            C_PARAMETER_POINTER: setPointerValue(regs, ram, param0, getPointerValue(regs, ram, param1));
        end;
    end;
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

  procedure exec(var c: TContext);
  begin
    with c.instruction.header do
    begin
      c.paramType0 := params shr 4;
      c.paramType1 := params and $0F;
    end;
    handlerVector[c.instruction.header.opcode](c);
  end;

begin
  registerOpcodes;
end.