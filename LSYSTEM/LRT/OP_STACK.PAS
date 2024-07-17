{
  this unit implements the stack functions of the CPU
}
unit 
  op_stack;

interface

  uses
    op_base,
    lcommon,
    lregs;

  procedure _push(const c: TContext); far;
  procedure _pop(const c: TContext); far;
  procedure _pusha(const c: TContext);
  procedure _popa(const c: TContext); far;

implementation

  procedure _push(const c: TContext);
  begin
    with c, instruction, regs^ do
    begin
      case paramType0 of
          C_PARAMETER_LITERAL: ram^.setValue(SS + SP, param0);
          C_PARAMETER_ADDRESS: ram^.setValue(SS + SP, ram^.getValue(param0));
          C_PARAMETER_REGISTER: ram^.setValue(SS + SP, getRegisterValue(regs, param0));
          C_PARAMETER_POINTER: ram^.setValue(SS + SP, getPointerValue(regs, ram, param0)); 
      end;
      inc(SP, sizeOf(TUInt32));        
      inc(IP, sizeOf(TInstruction));
    end;
  end;

  procedure _pop(const c: TContext);
  begin
    with c, instruction, regs^ do
    begin
      dec(SP, sizeOf(TUInt32));        
      case paramType0 of
          C_PARAMETER_ADDRESS: ram^.setValue(param0, ram^.getValue(SS + SP));
          C_PARAMETER_REGISTER: setRegisterValue(regs, param0, ram^.getValue(SS + SP));
          C_PARAMETER_POINTER: setPointerValue(regs, ram, param0, ram^.getValue(SS + SP)) 
      end;
      inc(IP, sizeOf(TInstruction));
    end;
  end;

  procedure _pusha(const c: TContext);
  begin
    with c, regs^ do
    begin
      ram^.setValue(SS + SP, EAX); inc(SP, sizeOf(TUInt32));        
      ram^.setValue(SS + SP, EBX); inc(SP, sizeOf(TUInt32));        
      ram^.setValue(SS + SP, ECX); inc(SP, sizeOf(TUInt32));        
      ram^.setValue(SS + SP, EDX); inc(SP, sizeOf(TUInt32));
      inc(IP, sizeOf(TInstruction));
    end;
  end;

  procedure _popa(const c: TContext);
  begin
    with c, regs^ do
    begin
      dec(SP, sizeOf(TUInt32)); EDX := ram^.getValue(SS + SP);
      dec(SP, sizeOf(TUInt32)); ECX := ram^.getValue(SS + SP);
      dec(SP, sizeOf(TUInt32)); EBX := ram^.getValue(SS + SP);
      dec(SP, sizeOf(TUInt32)); EAX := ram^.getValue(SS + SP);
      inc(IP, sizeOf(TInstruction));
    end;
  end;

end.