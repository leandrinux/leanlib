{
  this unit implements the input/output operations of the instruction set
}
unit
  op_io;

interface

  uses
    op_base,
    lcommon,
    lregs;

  procedure _out(const c: TContext); far;
  procedure _in(const c: TContext); far;

implementation

  procedure _out(const c: TContext);
  var
    device, value: byte;
    result: boolean;
  begin  
    with c, instruction, regs^ do 
    begin
      case paramType0 of
          C_PARAMETER_LITERAL: device := param0;
          C_PARAMETER_ADDRESS: device := ram^.getValue(param0);
          C_PARAMETER_REGISTER: device := getRegisterValue(regs, param0);
          C_PARAMETER_POINTER: device := getPointerValue(regs, ram, param0);
      end;
      case paramType1 of
          C_PARAMETER_LITERAL: value := param1;
          C_PARAMETER_ADDRESS: value := ram^.getValue(param1);
          C_PARAMETER_REGISTER: value := getRegisterValue(regs, param1);
          C_PARAMETER_POINTER: value := getPointerValue(regs, ram, param1);
      end;
      result := bus^.sendByte(device, value);
      if result then 
        CC := CC or C_CC_IO
      else
        CC := CC and (not C_CC_IO);
      inc(IP, sizeOf(TInstruction));
    end;
  end;

  procedure _in(const c: TContext);
  var
    device, value, bitsize: byte;
    finalValue: TUInt32;
    result: boolean;
  begin  

    with c, instruction, regs^ do 
    begin
      case paramType1 of
        C_PARAMETER_REGISTER: device := getRegisterValue(regs, param1);
      else
        cpuError(regs, C_ERR_INVALID_OPERATION)
      end;
      bitSize := getRegisterBitSize(param1);
      case paramType0 of
        C_PARAMETER_LITERAL: device := param0;
        C_PARAMETER_ADDRESS: device := ram^.getValue(param0);
        C_PARAMETER_REGISTER: device := getRegisterValue(regs, param0);
        C_PARAMETER_POINTER: device := getPointerValue(regs, ram, param0);
      end;
      
      { move forward instruction pointer and set IO flag to error by default }
      inc(IP, sizeOf(TInstruction));
      CC := CC or C_CC_IO;       

      result := bus^.receiveByte(device, value);
      if not result then exit; 
      if bitSize = 8 then    { return an 8 bit value }
      begin
        setRegisterValue(regs, param1, value);
        CC := CC and (not C_CC_IO);
        exit;
      end; 
      finalValue := value;
      result := bus^.receiveByte(device, value);
      if not result then exit;
      finalValue := finalValue or (longint(value) shl 8);
      if bitSize = 16 then   { return a 16 bit value }
      begin
        setRegisterValue(regs, param1, finalValue);
        CC := CC and (not C_CC_IO);
        exit;
      end;
      result := bus^.receiveByte(device, value);
      if not result then exit;
      finalValue := finalValue or (longint(value) shl 16);
      result := bus^.receiveByte(device, value);
      if not result then exit;
      finalValue := finalValue or (longint(value) shl 24);
      { return a 32-bit value }
      setRegisterValue(regs, param1, finalValue); 
      CC := CC and (not C_CC_IO);
    end;
  end;

end.