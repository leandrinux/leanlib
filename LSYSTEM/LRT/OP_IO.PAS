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
      result := bus^.receiveByte(device, value);
      if result then
      begin
        regs^.EAX := (regs^.EAX and $FFFFFF00) or value;
        CC := CC or C_CC_IO;
      end else
        CC := CC and (not C_CC_IO);
      inc(IP, sizeOf(TInstruction));
    end;
  end;

end.