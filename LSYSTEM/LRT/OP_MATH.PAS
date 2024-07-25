{
  this unit implements the math operations of the instruction set 
}
unit 
  op_math;

interface   

  uses
    op_base, lcommon;

  procedure _mov(const c: TContext); far;
  procedure _add(const c: TContext); far;
  procedure _sub(const c: TContext); far;
  procedure _mul(const c: TContext); far;
  procedure _div(const c: TContext); far;
  procedure _mod(const c: TContext); far;
  procedure _cmp(const c: TContext); far;

implementation

  procedure _mov(const c: TContext);
  begin
    if setParamValue(c, c.paramType0, c.instruction.param0, 
      getParamValue(c, c.paramType1, c.instruction.param1)
    ) then
    begin
      inc(c.regs^.IP, sizeOf(TInstruction));
    end;
  end;

  procedure _add(const c: TContext);
  var
    value, result: TUInt32;
  begin
    value := getParamValue(c, c.paramType1, c.instruction.param1);
    result := getParamValue(c, c.paramType0, c.instruction.param0) + value;
    if setParamValue(c, c.paramType0, c.instruction.param0, result) then
    begin
      setConditionCode(c.regs, result);
      inc(c.regs^.IP, sizeOf(TInstruction));
    end;
  end;

  procedure _sub(const c: TContext);
  var
    value, result: TUInt32;
  begin
    value := getParamValue(c, c.paramType1, c.instruction.param1);
    result := getParamValue(c, c.paramType0, c.instruction.param0) - value;
    if setParamValue(c, c.paramType0, c.instruction.param0, result) then
    begin
      setConditionCode(c.regs, result);
      inc(c.regs^.IP, sizeOf(TInstruction));
    end;
  end;

  procedure _mul(const c: TContext);
  var
    value, result: TUInt32;
  begin
    value := getParamValue(c, c.paramType1, c.instruction.param1);
    result := getParamValue(c, c.paramType0, c.instruction.param0) * value;
    if setParamValue(c, c.paramType0, c.instruction.param0, result) then
    begin
      setConditionCode(c.regs, result);
      inc(c.regs^.IP, sizeOf(TInstruction));
    end;
  end;

  procedure _div(const c: TContext);
  var
    value, result: TUInt32;
  begin
    value := getParamValue(c, c.paramType1, c.instruction.param1);
    if value = 0 then
    begin
      cpuError(c.regs, C_ERR_DIVIDE_BY_ZERO);
      exit;
    end;
    result := getParamValue(c, c.paramType0, c.instruction.param0) div value;
    if setParamValue(c, c.paramType0, c.instruction.param0, result) then
    begin
      setConditionCode(c.regs, result);
      inc(c.regs^.IP, sizeOf(TInstruction));
    end;
  end;

  procedure _mod(const c: TContext);
  var
    value, result: TUInt32;
  begin
    value := getParamValue(c, c.paramType1, c.instruction.param1);
    if value = 0 then
    begin
      cpuError(c.regs, C_ERR_DIVIDE_BY_ZERO);
      exit;
    end;
    result := getParamValue(c, c.paramType0, c.instruction.param0) mod value;
    if setParamValue(c, c.paramType0, c.instruction.param0, result) then
    begin
      setConditionCode(c.regs, result);
      inc(c.regs^.IP, sizeOf(TInstruction));
    end;
  end;

  procedure _cmp(const c: TContext);
  var
    value: TUInt32;
  begin
    value := getParamValue(c, c.paramType0, c.instruction.param0) - getParamValue(c, c.paramType1, c.instruction.param1);
    setConditionCode(c.regs, value);
    inc(c.regs^.IP, sizeOf(TInstruction));
  end;

end.