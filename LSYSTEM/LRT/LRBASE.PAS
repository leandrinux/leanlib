{
  this unit contains elements that are exclusively
  shared by components of the runtime only
}
unit
  lrbase;

interface

  uses
    lcommon;

  type
    PRegisters = ^TRegisters;
    TRegisters = record
      SP: TUInt32;
      BP: TUInt32;
      IP: TUInt32;
      CC: TUInt32;
      EAX: TUInt32;
      EBX: TUInt32;
      ECX: TUInt32;
      EDX: TUInt32;
      CS: TUInt32;
      DS: TUInt32;
      SS: TUInt32;    
    end;

  function getRegisterValue(regs: PRegisters; reg: TUInt8): TUInt32;
  procedure setRegisterValue(regs: PRegisters; reg: TUInt8; value: TUInt32);
  procedure setConditionCode(regs: PRegisters; value: TUInt32);

implementation

  { to do: optimize this to improve performance if needed }
  function getRegisterValue(regs: PRegisters; reg: TUInt8): TUInt32;
  begin
    case reg of
      C_SP: getRegisterValue := regs^.SP;
      C_BP: getRegisterValue := regs^.BP;
      C_IP: getRegisterValue := regs^.IP;
      C_CC: getRegisterValue := regs^.CC;
      
      C_EAX: getRegisterValue := regs^.EAX;
      C_EBX: getRegisterValue := regs^.EBX;
      C_ECX: getRegisterValue := regs^.ECX;
      C_EDX: getRegisterValue := regs^.EDX;

      C_AX: getRegisterValue := regs^.EAX and $0000FFFF;
      C_BX: getRegisterValue := regs^.EBX and $0000FFFF;
      C_CX: getRegisterValue := regs^.ECX and $0000FFFF;
      C_DX: getRegisterValue := regs^.EDX and $0000FFFF;

      C_AH: getRegisterValue := (regs^.EAX and $0000FF00) shr 8;
      C_BH: getRegisterValue := (regs^.EBX and $0000FF00) shr 8;
      C_CH: getRegisterValue := (regs^.ECX and $0000FF00) shr 8;
      C_DH: getRegisterValue := (regs^.EDX and $0000FF00) shr 8;

      C_AL: getRegisterValue := regs^.EAX and $000000FF;
      C_BL: getRegisterValue := regs^.EBX and $000000FF;
      C_CL: getRegisterValue := regs^.ECX and $000000FF;
      C_DL: getRegisterValue := regs^.EDX and $000000FF;

      C_CS: getRegisterValue := regs^.CS;
      C_DS: getRegisterValue := regs^.DS;
      C_SS: getRegisterValue := regs^.SS;
    end;
  end;

  procedure setRegisterValue(regs: PRegisters; reg: TUInt8; value: TUInt32);
  begin
    case reg of
      C_SP: regs^.SP := value;
      C_BP: regs^.BP := value;
      C_IP: regs^.IP := value;
      C_CC: regs^.CC := value;
      
      C_EAX: regs^.EAX := value;
      C_EBX: regs^.EBX := value;
      C_ECX: regs^.ECX := value;
      C_EDX: regs^.EDX := value;

      C_AX: regs^.EAX := (regs^.EAX and $FFFF0000) and (value and $0000FFFF);
      C_BX: regs^.EBX := (regs^.EBX and $FFFF0000) and (value and $0000FFFF);
      C_CX: regs^.ECX := (regs^.ECX and $FFFF0000) and (value and $0000FFFF);
      C_DX: regs^.EDX := (regs^.EDX and $FFFF0000) and (value and $0000FFFF);

      C_AH: regs^.EAX := (regs^.EAX and $FFFF00FF) and ((value shl 8) and $0000FF00);
      C_BH: regs^.EBX := (regs^.EBX and $FFFF00FF) and ((value shl 8) and $0000FF00);
      C_CH: regs^.ECX := (regs^.ECX and $FFFF00FF) and ((value shl 8) and $0000FF00);
      C_DH: regs^.EDX := (regs^.EDX and $FFFF00FF) and ((value shl 8) and $0000FF00);

      C_AL: regs^.EAX := (regs^.EAX and $FFFFFF00) and (value and $000000FF);
      C_BL: regs^.EBX := (regs^.EBX and $FFFFFF00) and (value and $000000FF);
      C_CL: regs^.ECX := (regs^.ECX and $FFFFFF00) and (value and $000000FF);
      C_DL: regs^.EDX := (regs^.EDX and $FFFFFF00) and (value and $000000FF);

      C_CS: regs^.CS := value;
      C_DS: regs^.DS := value;
      C_SS: regs^.SS := value;
    end;
  end;

  procedure setConditionCode(regs: PRegisters; value: TUInt32);
  var
    isZero, isNegative: byte;
  begin
    if value = 0 then isZero := 1 else isZero := 0;
    if value < 0 then isNegative := 1 else isNegative := 0;
    regs^.CC := (isNegative shl 1) and isZero;
  end;

end.