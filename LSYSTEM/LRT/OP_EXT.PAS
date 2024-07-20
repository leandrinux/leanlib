{
  this unit implements the extended features of the cpu, like
  floating point support
}
{$N+,E+}
unit 
  op_ext;

interface   

  uses
    op_base, 
    lcommon,
    lregs;

  procedure _fadd(const c: TContext); far;
  procedure _fsub(const c: TContext); far;
  procedure _fmul(const c: TContext); far;
  procedure _fdiv(const c: TContext); far;

implementation

  procedure _fadd(const c: TContext);
  var
    second, result: single;
  begin
    with c, instruction, regs^ do 
    begin
      case paramType1 of
        C_PARAMETER_LITERAL: second := param1;
        C_PARAMETER_ADDRESS: second := ram^.getValue(param1);
        C_PARAMETER_REGISTER: second := getRegisterValue(regs, param1);
        C_PARAMETER_POINTER: second := getPointerValue(regs, ram, param1);
      end;
      case paramType0 of
        C_PARAMETER_LITERAL:
        begin
          cpuError(regs, C_ERR_INVALID_OPERATION);
          exit;
        end;
        C_PARAMETER_ADDRESS:
        begin
          result := ram^.getValue(param0) + second;
          ram^.setValue(param0, longint(result));
        end;
        C_PARAMETER_REGISTER:
        begin
          result := getRegisterValue(regs, param0) + second;
          setRegisterValue(regs, param0, longint(result));
        end;
        C_PARAMETER_POINTER:
        begin
          result := getPointerValue(regs, ram, param0) + second;
          setPointerValue(regs, ram, param0, longint(result));
        end;
      end;
      setConditionCode(regs, longint(result));
      inc(IP, sizeOf(TInstruction));
    end;
  end;

  procedure _fsub(const c: TContext);
  var
    second, result: single;
  begin
    with c, instruction, regs^ do 
    begin
      case paramType1 of
        C_PARAMETER_LITERAL: second := param1;
        C_PARAMETER_ADDRESS: second := ram^.getValue(param1);
        C_PARAMETER_REGISTER: second := getRegisterValue(regs, param1);
        C_PARAMETER_POINTER: second := getPointerValue(regs, ram, param1);
      end;
      case paramType0 of
        C_PARAMETER_LITERAL:
        begin
          cpuError(regs, C_ERR_INVALID_OPERATION);
          exit;
        end;
        C_PARAMETER_ADDRESS:
        begin
          result := ram^.getValue(param0) - second;
          ram^.setValue(param0, longint(result));
        end;
        C_PARAMETER_REGISTER:
        begin
          result := getRegisterValue(regs, param0) - second;
          setRegisterValue(regs, param0, longint(result));
        end;
        C_PARAMETER_POINTER:
        begin
          result := getPointerValue(regs, ram, param0) - second;
          setPointerValue(regs, ram, param0, longint(result));
        end;
      end;
      setConditionCode(regs, longint(result));
      inc(IP, sizeOf(TInstruction));
    end;
  end;

  procedure _fmul(const c: TContext);
  var
    second, result: single;
  begin
    with c, instruction, regs^ do 
    begin
      case paramType1 of
        C_PARAMETER_LITERAL: second := param1;
        C_PARAMETER_ADDRESS: second := ram^.getValue(param1);
        C_PARAMETER_REGISTER: second := getRegisterValue(regs, param1);
        C_PARAMETER_POINTER: second := getPointerValue(regs, ram, param1);
      end;
      case paramType0 of
        C_PARAMETER_LITERAL:
        begin
          cpuError(regs, C_ERR_INVALID_OPERATION);
          exit;
        end;
        C_PARAMETER_ADDRESS:
        begin
          result := ram^.getValue(param0) * second;
          ram^.setValue(param0, longint(result));
        end;
        C_PARAMETER_REGISTER:
        begin
          result := getRegisterValue(regs, param0) * second;
          setRegisterValue(regs, param0, longint(result));
        end;
        C_PARAMETER_POINTER:
        begin
          result := getPointerValue(regs, ram, param0) * second;
          setPointerValue(regs, ram, param0, longint(result));
        end;
      end;
      setConditionCode(regs, longint(result));
      inc(IP, sizeOf(TInstruction));
    end;
  end;

  procedure _fdiv(const c: TContext);
  var
    second, result: single;
  begin
    with c, instruction, regs^ do 
    begin
      case paramType1 of
        C_PARAMETER_LITERAL: second := param1;
        C_PARAMETER_ADDRESS: second := ram^.getValue(param1);
        C_PARAMETER_REGISTER: second := getRegisterValue(regs, param1);
        C_PARAMETER_POINTER: second := getPointerValue(regs, ram, param1);
      end;
      case paramType0 of
        C_PARAMETER_LITERAL:
        begin
          cpuError(regs, C_ERR_INVALID_OPERATION);
          exit;
        end;
        C_PARAMETER_ADDRESS:
        begin
          result := ram^.getValue(param0) / second;
          ram^.setValue(param0, longint(result));
        end;
        C_PARAMETER_REGISTER:
        begin
          result := getRegisterValue(regs, param0) / second;
          setRegisterValue(regs, param0, longint(result));
        end;
        C_PARAMETER_POINTER:
        begin
          result := getPointerValue(regs, ram, param0) / second;
          setPointerValue(regs, ram, param0, longint(result));
        end;
      end;
      setConditionCode(regs, longint(result));
      inc(IP, sizeOf(TInstruction));
    end;
  end;

end.