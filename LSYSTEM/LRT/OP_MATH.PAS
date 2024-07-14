{
  this unit implements the math operations of the instruction set 
}
unit 
  op_math;

interface   

  uses
    op_base, 
    lcommon,
    lrbase;

  procedure _mov(const c: TContext); far;
  procedure _sub(const c: TContext); far;

implementation

  procedure _mov(const c: TContext);
  begin
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

  procedure _sub(const c: TContext);
  var
    value: TUInt32;
  begin
    with c, instruction do case paramType0 of
      C_PARAMETER_ADDRESS:
      begin
        case paramType1 of
            C_PARAMETER_LITERAL: value := ram^.getValue(param0) - param1;
            C_PARAMETER_ADDRESS: value := ram^.getValue(param0) - ram^.getValue(param1);
            C_PARAMETER_REGISTER: value := ram^.getValue(param0) - getRegisterValue(regs, param1);
            C_PARAMETER_POINTER: value := ram^.getValue(param0) - getPointerValue(regs, ram, param1);
        end;
        ram^.setValue(param0, value);
      end;

      C_PARAMETER_REGISTER:
      begin
        case paramType1 of
            C_PARAMETER_LITERAL: value := getRegisterValue(regs, param0) - param1;
            C_PARAMETER_ADDRESS: value := getRegisterValue(regs, param0) - ram^.getValue(param1);
            C_PARAMETER_REGISTER: value := getRegisterValue(regs, param0) - getRegisterValue(regs, param1);
            C_PARAMETER_POINTER: value := getRegisterValue(regs, param0) - getPointerValue(regs, ram, param1);
        end;
        setRegisterValue(regs, param0, value);
      end;

      C_PARAMETER_POINTER:
      begin
        case paramType1 of
            C_PARAMETER_LITERAL: value := getPointerValue(regs, ram, param0) - param1;
            C_PARAMETER_ADDRESS: value := getPointerValue(regs, ram, param0) - ram^.getValue(param1);
            C_PARAMETER_REGISTER: value := getPointerValue(regs, ram, param0) - getRegisterValue(regs, param1);
            C_PARAMETER_POINTER: value := getPointerValue(regs, ram, param0) - getPointerValue(regs, ram, param1);
        end;
        setPointerValue(regs, ram, param0, value);
      end;

    end;
  end;

end.