{
  Basic types and procedures needed to implement the instruction set
}
unit
  op_base;

interface

  uses
    lcommon, lram, lbus;

  const
    C_STACK_REGISTERS = [C_SS, C_SP, C_BP];

  type
    TContext = record
      instruction: TInstruction;
      paramType0, paramType1: byte;
      regs: PRegisters;
      ram: PRAM;
      bus: PBus;
      stackSize: TUInt32;
    end;

  function getRegisterValue(regs: PRegisters; reg: TUInt8): TUInt32;
  procedure setRegisterValue(regs: PRegisters; reg: TUInt8; value: TUInt32);
  function getPointerValue(regs: PRegisters; ram: PRAM; param: TUInt32): TUInt32;
  procedure setPointerValue(regs: PRegisters; ram: PRAM; param, value: TUInt32);
  function getParamValue(const c: TContext; paramType, param: TUInt32): TUInt32;
  function setParamValue(const c: TContext; paramType, param, value: TUInt32): boolean;
  procedure cpuError(regs: PRegisters; code: TUInt32);
  function getRegisterBitSize(const param: TUInt32): byte;
  procedure setConditionCode(regs: PRegisters; value: TUInt32);

implementation

  function getRegisterValue(regs: PRegisters; reg: TUInt8): TUInt32;
  begin
    case reg of
      C_EAX: getRegisterValue := regs^.EAX;
      C_EBX: getRegisterValue := regs^.EBX;
      C_ECX: getRegisterValue := regs^.ECX;
      C_EDX: getRegisterValue := regs^.EDX;

      C_IP: getRegisterValue := regs^.IP;

      C_SP: getRegisterValue := regs^.SP;
      C_BP: getRegisterValue := regs^.BP;
      C_CC: getRegisterValue := regs^.CC;
      
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
      C_EAX: regs^.EAX := value;
      C_EBX: regs^.EBX := value;
      C_ECX: regs^.ECX := value;
      C_EDX: regs^.EDX := value;

      C_SP: regs^.SP := value;
      C_BP: regs^.BP := value;
      C_IP: regs^.IP := value;
      C_CC: regs^.CC := value;

      C_AX: regs^.EAX := (regs^.EAX and $FFFF0000) or (value and $0000FFFF);
      C_BX: regs^.EBX := (regs^.EBX and $FFFF0000) or (value and $0000FFFF);
      C_CX: regs^.ECX := (regs^.ECX and $FFFF0000) or (value and $0000FFFF);
      C_DX: regs^.EDX := (regs^.EDX and $FFFF0000) or (value and $0000FFFF);

      C_AH: regs^.EAX := (regs^.EAX and $FFFF00FF) or ((value shl 8) and $0000FF00);
      C_BH: regs^.EBX := (regs^.EBX and $FFFF00FF) or ((value shl 8) and $0000FF00);
      C_CH: regs^.ECX := (regs^.ECX and $FFFF00FF) or ((value shl 8) and $0000FF00);
      C_DH: regs^.EDX := (regs^.EDX and $FFFF00FF) or ((value shl 8) and $0000FF00);

      C_AL: regs^.EAX := (regs^.EAX and $FFFFFF00) or (value and $000000FF);
      C_BL: regs^.EBX := (regs^.EBX and $FFFFFF00) or (value and $000000FF);
      C_CL: regs^.ECX := (regs^.ECX and $FFFFFF00) or (value and $000000FF);
      C_DL: regs^.EDX := (regs^.EDX and $FFFFFF00) or (value and $000000FF);

      C_CS: regs^.CS := value;
      C_DS: regs^.DS := value;
      C_SS: regs^.SS := value;
    end;
  end;

  function getPointerValue(regs: PRegisters; ram: PRAM; param: TUInt32): TUInt32;
  var
    address: TUInt32;
    reg: byte;
  begin
    reg := param and $FF;
    address := getRegisterValue(regs, reg) + (param shr 16);
    if reg in C_STACK_REGISTERS then inc(address, regs^.SS) else inc(address, regs^.DS);
    getPointerValue := ram^.getValue(address);
  end;

  procedure setPointerValue(regs: PRegisters; ram: PRAM; param, value: TUInt32);
  var
    address: TUInt32;
    reg: byte;
  begin
    reg := param and $FF;
    address := getRegisterValue(regs, reg) + (param shr 16);
    if reg in C_STACK_REGISTERS then inc(address, regs^.SS) else inc(address, regs^.DS);
    ram^.setValue(address, value);
  end;

  function getParamValue(const c: TContext; paramType, param: TUInt32): TUInt32;
  begin
    with c do 
      case paramType of
        C_PARAMETER_LITERAL: getParamValue := param;
        C_PARAMETER_ADDRESS: getParamValue := ram^.getValue(regs^.DS + param);
        C_PARAMETER_REGISTER: getParamValue := getRegisterValue(regs, param);
        C_PARAMETER_POINTER: getParamValue := getPointerValue(regs, ram, param);
      end;
  end;

  function setParamValue(const c: TContext; paramType, param, value: TUInt32): boolean;
  begin
    setParamValue := true;
    with c do 
      case paramType of
        C_PARAMETER_LITERAL: 
        begin
          cpuError(regs, C_ERR_INVALID_OPERATION);
          setParamValue := false;
        end;

        C_PARAMETER_ADDRESS: 
          ram^.setValue(regs^.DS + param, value);

        C_PARAMETER_REGISTER: 
          setRegisterValue(regs, param, value);

        C_PARAMETER_POINTER: 
          setPointerValue(regs, ram, param, value);
      end;
  end;

  procedure cpuError(regs: PRegisters; code: TUInt32);
  begin
    with regs^ do
    begin
      CC := CC OR C_CC_ERR;
      EAX := code;
      EBX := IP;
      SP := 0;
      IP := 0;
    end;
  end;

  function getRegisterBitSize(const param: TUInt32): byte;
  begin
    case param of
      C_AH, C_BH, C_CH, C_DH, C_AL, C_BL, C_CL, C_DL: 
        getRegisterBitSize := 8;

      C_AX, C_BX, C_CX, C_DX: 
        getRegisterBitSize := 16;
    else
      getRegisterBitSize := 32;
    end;       
  end;

  procedure setConditionCode(regs: PRegisters; value: TUInt32);
  var
    isZero, isNegative: byte;
  begin
    if value = 0 then isZero := 1 else isZero := 0;
    if value < 0 then isNegative := 1 else isNegative := 0;
    regs^.CC := (isNegative shl 1) or isZero;
  end;

end.