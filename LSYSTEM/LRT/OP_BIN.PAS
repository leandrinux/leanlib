{
  this unit implements the math operations of the instruction set 
}
unit 
  op_bin;

interface   

  uses
    op_base, 
    lcommon,
    lregs;

  procedure _and(const c: TContext); far;
  procedure _or(const c: TContext); far;
  procedure _not(const c: TContext); far;
  procedure _xor(const c: TContext); far;
  procedure _shl(const c: TContext); far;
  procedure _shr(const c: TContext); far;

implementation

  procedure _and(const c: TContext);
  var
    value: TUInt32;
  begin
    with c, instruction do case paramType0 of
      C_PARAMETER_ADDRESS:
      begin
        case paramType1 of
            C_PARAMETER_LITERAL: value := ram^.getValue(param0) and param1;
            C_PARAMETER_ADDRESS: value := ram^.getValue(param0) and ram^.getValue(param1);
            C_PARAMETER_REGISTER: value := ram^.getValue(param0) and getRegisterValue(regs, param1);
            C_PARAMETER_POINTER: value := ram^.getValue(param0) and getPointerValue(regs, ram, param1);
        end;
        ram^.setValue(param0, value);
      end;
      C_PARAMETER_REGISTER:
      begin
        case paramType1 of
            C_PARAMETER_LITERAL: value := getRegisterValue(regs, param0) and param1;
            C_PARAMETER_ADDRESS: value := getRegisterValue(regs, param0) and ram^.getValue(param1);
            C_PARAMETER_REGISTER: value := getRegisterValue(regs, param0) and getRegisterValue(regs, param1);
            C_PARAMETER_POINTER: value := getRegisterValue(regs, param0) and getPointerValue(regs, ram, param1);
        end;
        setRegisterValue(regs, param0, value);
      end;
      C_PARAMETER_POINTER:
      begin
        case paramType1 of
            C_PARAMETER_LITERAL: value := getPointerValue(regs, ram, param0) and param1;
            C_PARAMETER_ADDRESS: value := getPointerValue(regs, ram, param0) and ram^.getValue(param1);
            C_PARAMETER_REGISTER: value := getPointerValue(regs, ram, param0) and getRegisterValue(regs, param1);
            C_PARAMETER_POINTER: value := getPointerValue(regs, ram, param0) and getPointerValue(regs, ram, param1);
        end;
        setPointerValue(regs, ram, param0, value);
      end;
    end;
    setConditionCode(c.regs, value);
    inc(c.regs^.IP, sizeOf(TInstruction));
  end;
 
  procedure _or(const c: TContext);
  var
    value: TUInt32;
  begin
    with c, instruction do case paramType0 of
      C_PARAMETER_ADDRESS:
      begin
        case paramType1 of
            C_PARAMETER_LITERAL: value := ram^.getValue(param0) or param1;
            C_PARAMETER_ADDRESS: value := ram^.getValue(param0) or ram^.getValue(param1);
            C_PARAMETER_REGISTER: value := ram^.getValue(param0) or getRegisterValue(regs, param1);
            C_PARAMETER_POINTER: value := ram^.getValue(param0) or getPointerValue(regs, ram, param1);
        end;
        ram^.setValue(param0, value);
      end;
      C_PARAMETER_REGISTER:
      begin
        case paramType1 of
            C_PARAMETER_LITERAL: value := getRegisterValue(regs, param0) or param1;
            C_PARAMETER_ADDRESS: value := getRegisterValue(regs, param0) or ram^.getValue(param1);
            C_PARAMETER_REGISTER: value := getRegisterValue(regs, param0) or getRegisterValue(regs, param1);
            C_PARAMETER_POINTER: value := getRegisterValue(regs, param0) or getPointerValue(regs, ram, param1);
        end;
        setRegisterValue(regs, param0, value);
      end;
      C_PARAMETER_POINTER:
      begin
        case paramType1 of
            C_PARAMETER_LITERAL: value := getPointerValue(regs, ram, param0) or param1;
            C_PARAMETER_ADDRESS: value := getPointerValue(regs, ram, param0) or ram^.getValue(param1);
            C_PARAMETER_REGISTER: value := getPointerValue(regs, ram, param0) or getRegisterValue(regs, param1);
            C_PARAMETER_POINTER: value := getPointerValue(regs, ram, param0) or getPointerValue(regs, ram, param1);
        end;
        setPointerValue(regs, ram, param0, value);
      end;
    end;
    setConditionCode(c.regs, value);
    inc(c.regs^.IP, sizeOf(TInstruction));
  end;

 procedure _not(const c: TContext);
  var
    value: TUInt32;
  begin
    with c, instruction do case paramType0 of
      C_PARAMETER_ADDRESS: ram^.setValue(param0, not ram^.getValue(param0));
      C_PARAMETER_REGISTER: setRegisterValue(regs, param0, not getRegisterValue(regs, param0));
      C_PARAMETER_POINTER: setPointerValue(regs, ram, param0, not getPointerValue(regs, ram, param0));
    end;
    setConditionCode(c.regs, value);
    inc(c.regs^.IP, sizeOf(TInstruction));
  end;

  procedure _xor(const c: TContext);
  var
    value: TUInt32;
  begin
    with c, instruction do case paramType0 of
      C_PARAMETER_ADDRESS:
      begin
        case paramType1 of
            C_PARAMETER_LITERAL: value := ram^.getValue(param0) xor param1;
            C_PARAMETER_ADDRESS: value := ram^.getValue(param0) xor ram^.getValue(param1);
            C_PARAMETER_REGISTER: value := ram^.getValue(param0) xor getRegisterValue(regs, param1);
            C_PARAMETER_POINTER: value := ram^.getValue(param0) xor getPointerValue(regs, ram, param1);
        end;
        ram^.setValue(param0, value);
      end;
      C_PARAMETER_REGISTER:
      begin
        case paramType1 of
            C_PARAMETER_LITERAL: value := getRegisterValue(regs, param0) xor param1;
            C_PARAMETER_ADDRESS: value := getRegisterValue(regs, param0) xor ram^.getValue(param1);
            C_PARAMETER_REGISTER: value := getRegisterValue(regs, param0) xor getRegisterValue(regs, param1);
            C_PARAMETER_POINTER: value := getRegisterValue(regs, param0) xor getPointerValue(regs, ram, param1);
        end;
        setRegisterValue(regs, param0, value);
      end;
      C_PARAMETER_POINTER:
      begin
        case paramType1 of
            C_PARAMETER_LITERAL: value := getPointerValue(regs, ram, param0) xor param1;
            C_PARAMETER_ADDRESS: value := getPointerValue(regs, ram, param0) xor ram^.getValue(param1);
            C_PARAMETER_REGISTER: value := getPointerValue(regs, ram, param0) xor getRegisterValue(regs, param1);
            C_PARAMETER_POINTER: value := getPointerValue(regs, ram, param0) xor getPointerValue(regs, ram, param1);
        end;
        setPointerValue(regs, ram, param0, value);
      end;
    end;
    setConditionCode(c.regs, value);
    inc(c.regs^.IP, sizeOf(TInstruction));
  end;

  procedure _shl(const c: TContext);
  var
    value: TUInt32;
  begin
    with c, instruction do case paramType0 of
      C_PARAMETER_ADDRESS:
      begin
        case paramType1 of
            C_PARAMETER_LITERAL: value := ram^.getValue(param0) shl param1;
            C_PARAMETER_ADDRESS: value := ram^.getValue(param0) shl ram^.getValue(param1);
            C_PARAMETER_REGISTER: value := ram^.getValue(param0) shl getRegisterValue(regs, param1);
            C_PARAMETER_POINTER: value := ram^.getValue(param0) shl getPointerValue(regs, ram, param1);
        end;
        ram^.setValue(param0, value);
      end;
      C_PARAMETER_REGISTER:
      begin
        case paramType1 of
            C_PARAMETER_LITERAL: value := getRegisterValue(regs, param0) shl param1;
            C_PARAMETER_ADDRESS: value := getRegisterValue(regs, param0) shl ram^.getValue(param1);
            C_PARAMETER_REGISTER: value := getRegisterValue(regs, param0) shl getRegisterValue(regs, param1);
            C_PARAMETER_POINTER: value := getRegisterValue(regs, param0) shl getPointerValue(regs, ram, param1);
        end;
        setRegisterValue(regs, param0, value);
      end;
      C_PARAMETER_POINTER:
      begin
        case paramType1 of
            C_PARAMETER_LITERAL: value := getPointerValue(regs, ram, param0) shl param1;
            C_PARAMETER_ADDRESS: value := getPointerValue(regs, ram, param0) shl ram^.getValue(param1);
            C_PARAMETER_REGISTER: value := getPointerValue(regs, ram, param0) shl getRegisterValue(regs, param1);
            C_PARAMETER_POINTER: value := getPointerValue(regs, ram, param0) shl getPointerValue(regs, ram, param1);
        end;
        setPointerValue(regs, ram, param0, value);
      end;
    end;
    setConditionCode(c.regs, value);
    inc(c.regs^.IP, sizeOf(TInstruction));
  end;


  procedure _shr(const c: TContext);
  var
    value: TUInt32;
  begin
    with c, instruction do case paramType0 of
      C_PARAMETER_ADDRESS:
      begin
        case paramType1 of
            C_PARAMETER_LITERAL: value := ram^.getValue(param0) shr param1;
            C_PARAMETER_ADDRESS: value := ram^.getValue(param0) shr ram^.getValue(param1);
            C_PARAMETER_REGISTER: value := ram^.getValue(param0) shr getRegisterValue(regs, param1);
            C_PARAMETER_POINTER: value := ram^.getValue(param0) shr getPointerValue(regs, ram, param1);
        end;
        ram^.setValue(param0, value);
      end;
      C_PARAMETER_REGISTER:
      begin
        case paramType1 of
            C_PARAMETER_LITERAL: value := getRegisterValue(regs, param0) shr param1;
            C_PARAMETER_ADDRESS: value := getRegisterValue(regs, param0) shr ram^.getValue(param1);
            C_PARAMETER_REGISTER: value := getRegisterValue(regs, param0) shr getRegisterValue(regs, param1);
            C_PARAMETER_POINTER: value := getRegisterValue(regs, param0) shr getPointerValue(regs, ram, param1);
        end;
        setRegisterValue(regs, param0, value);
      end;
      C_PARAMETER_POINTER:
      begin
        case paramType1 of
            C_PARAMETER_LITERAL: value := getPointerValue(regs, ram, param0) shr param1;
            C_PARAMETER_ADDRESS: value := getPointerValue(regs, ram, param0) shr ram^.getValue(param1);
            C_PARAMETER_REGISTER: value := getPointerValue(regs, ram, param0) shr getRegisterValue(regs, param1);
            C_PARAMETER_POINTER: value := getPointerValue(regs, ram, param0) shr getPointerValue(regs, ram, param1);
        end;
        setPointerValue(regs, ram, param0, value);
      end;
    end;
    setConditionCode(c.regs, value);
    inc(c.regs^.IP, sizeOf(TInstruction));
  end;

end.