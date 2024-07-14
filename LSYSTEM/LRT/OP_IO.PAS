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
    with c, instruction do case paramType0 of
      C_PARAMETER_LITERAL:
        case paramType1 of
            C_PARAMETER_LITERAL: bus^.sendByte(param0, param1);
            C_PARAMETER_ADDRESS: bus^.sendByte(param0, ram^.getValue(param1));
            C_PARAMETER_REGISTER: bus^.sendByte(param0, getRegisterValue(regs, param1));
            C_PARAMETER_POINTER: bus^.sendByte(param0, getPointerValue(regs, ram, param1));
        end;
      C_PARAMETER_ADDRESS:
        case paramType1 of
            C_PARAMETER_LITERAL: bus^.sendByte(ram^.getValue(param0), param1);
            C_PARAMETER_ADDRESS: bus^.sendByte(ram^.getValue(param0), ram^.getValue(param1));
            C_PARAMETER_REGISTER: bus^.sendByte(ram^.getValue(param0), getRegisterValue(regs, param1));
            C_PARAMETER_POINTER: bus^.sendByte(ram^.getValue(param0), getPointerValue(regs, ram, param1));
        end;
      C_PARAMETER_REGISTER:
        case paramType1 of
            C_PARAMETER_LITERAL: bus^.sendByte(getRegisterValue(regs, param0), param1);
            C_PARAMETER_ADDRESS: bus^.sendByte(getRegisterValue(regs, param0), ram^.getValue(param1));
            C_PARAMETER_REGISTER: bus^.sendByte(getRegisterValue(regs, param0), getRegisterValue(regs, param1));
            C_PARAMETER_POINTER: bus^.sendByte(getRegisterValue(regs, param0), getPointerValue(regs, ram, param1));
        end;
      C_PARAMETER_POINTER:
        case paramType1 of
            C_PARAMETER_LITERAL: bus^.sendByte(getPointerValue(regs, ram, param0), param1);
            C_PARAMETER_ADDRESS: bus^.sendByte(getPointerValue(regs, ram, param0), ram^.getValue(param1));
            C_PARAMETER_REGISTER: bus^.sendByte(getPointerValue(regs, ram, param0), getRegisterValue(regs, param1));
            C_PARAMETER_POINTER: bus^.sendByte(getPointerValue(regs, ram, param0), getPointerValue(regs, ram, param1));
        end;
    end;
    setRegisterValue(c.regs, C_IP, getRegisterValue(c.regs, C_IP) + sizeOf(TInstruction));
  end;


end.