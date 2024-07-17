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
      ram^.setValue(SS + SP, getRegisterValue(regs, param0));
      inc(SP, sizeOf(TUInt32));        
      inc(IP, sizeOf(TInstruction));
    end;
  end;

  procedure _pop(const c: TContext);
  begin
    with c, instruction, regs^ do
    begin
      dec(SP, sizeOf(TUInt32));        
      setRegisterValue(regs, param0, ram^.getValue(SS + SP));
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