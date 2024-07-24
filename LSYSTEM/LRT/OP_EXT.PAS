{
  this unit implements the extended features of the cpu, like
  floating point support
}
{$N+,E+}
unit 
  op_ext;

interface   

  uses
    op_base, lcommon;

  procedure _fadd(const c: TContext); far;
  procedure _fsub(const c: TContext); far;
  procedure _fmul(const c: TContext); far;
  procedure _fdiv(const c: TContext); far;

implementation

  procedure _fadd(const c: TContext);
  var
    second, result: single;
  begin
    second := getParamValue(c, c.paramType1, c.instruction.param1);
    result := getParamValue(c, c.paramType0, c.instruction.param0) + second;
    if setParamValue(c, c.paramType0, c.instruction.param0, TUInt32(result)) then
    begin
      setConditionCode(c.regs, TUInt32(result));
      inc(c.regs^.IP, sizeOf(TInstruction));
    end;
  end;

  procedure _fsub(const c: TContext);
  var
    second, result: single;
  begin
    second := getParamValue(c, c.paramType1, c.instruction.param1);
    result := getParamValue(c, c.paramType0, c.instruction.param0) - second;
    if setParamValue(c, c.paramType0, c.instruction.param0, TUInt32(result)) then
    begin
      setConditionCode(c.regs, TUInt32(result));
      inc(c.regs^.IP, sizeOf(TInstruction));
    end;
  end;

  procedure _fmul(const c: TContext);
  var
    second, result: single;
  begin
    second := getParamValue(c, c.paramType1, c.instruction.param1);
    result := getParamValue(c, c.paramType0, c.instruction.param0) * second;
    if setParamValue(c, c.paramType0, c.instruction.param0, TUInt32(result)) then
    begin
      setConditionCode(c.regs, TUInt32(result));
      inc(c.regs^.IP, sizeOf(TInstruction));
    end;
  end;

  procedure _fdiv(const c: TContext);
  var
    second, result: single;
  begin
    second := getParamValue(c, c.paramType1, c.instruction.param1);
    if second = 0 then
    begin
      cpuError(c.regs, C_ERR_DIVIDE_BY_ZERO);
      exit;
    end;
    result := getParamValue(c, c.paramType0, c.instruction.param0) / second;
    if setParamValue(c, c.paramType0, c.instruction.param0, TUInt32(result)) then
    begin
      setConditionCode(c.regs, TUInt32(result));
      inc(c.regs^.IP, sizeOf(TInstruction));
    end;
  end;

end.