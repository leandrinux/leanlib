{
  this unit implements the math operations of the instruction set 
}
unit 
  op_bin;

interface   

  uses
    op_base, lcommon;

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
    value := getParamValue(c, c.paramType1, c.instruction.param1);
    if setParamValue(c, c.paramType0, c.instruction.param0, 
      getParamValue(c, c.paramType0, c.instruction.param0) and value
    ) then
    begin
      setConditionCode(c.regs, value);
      inc(c.regs^.IP, sizeOf(TInstruction));
    end;
  end;
 
  procedure _or(const c: TContext);
  var
    value: TUInt32;
  begin
    value := getParamValue(c, c.paramType1, c.instruction.param1);
    if setParamValue(c, c.paramType0, c.instruction.param0, 
      getParamValue(c, c.paramType0, c.instruction.param0) or value
    ) then
    begin
      setConditionCode(c.regs, value);
      inc(c.regs^.IP, sizeOf(TInstruction));
    end;
  end;

  procedure _not(const c: TContext);
  var
    value: TUInt32;
  begin
    value := getParamValue(c, c.paramType1, c.instruction.param1);
    if setParamValue(c, c.paramType0, c.instruction.param0, 
      not getParamValue(c, c.paramType0, c.instruction.param0)
    ) then
    begin
      setConditionCode(c.regs, value);
      inc(c.regs^.IP, sizeOf(TInstruction));
    end;
  end;

  procedure _xor(const c: TContext);
  var
    value: TUInt32;
  begin
    value := getParamValue(c, c.paramType1, c.instruction.param1);
    if setParamValue(c, c.paramType0, c.instruction.param0, 
      getParamValue(c, c.paramType0, c.instruction.param0) xor value
    ) then
    begin
      setConditionCode(c.regs, value);
      inc(c.regs^.IP, sizeOf(TInstruction));
    end;
  end;

  procedure _shl(const c: TContext);
  var
    value: TUInt32;
  begin
    value := getParamValue(c, c.paramType1, c.instruction.param1);
    if setParamValue(c, c.paramType0, c.instruction.param0, 
      getParamValue(c, c.paramType0, c.instruction.param0) shl value
    ) then
    begin
      setConditionCode(c.regs, value);
      inc(c.regs^.IP, sizeOf(TInstruction));
    end;
  end;

  procedure _shr(const c: TContext);
  var
    value: TUInt32;
  begin
    value := getParamValue(c, c.paramType1, c.instruction.param1);
    if setParamValue(c, c.paramType0, c.instruction.param0, 
      getParamValue(c, c.paramType0, c.instruction.param0) shr value
    ) then
    begin
      setConditionCode(c.regs, value);
      inc(c.regs^.IP, sizeOf(TInstruction));
    end;
  end;

end.