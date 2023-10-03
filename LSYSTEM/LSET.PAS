unit
  lset;

interface

  uses
    lcommon;

  type
    TOperationData = packed record
      systemState: PSystemState;
      type0, type1: byte;
      arg0, arg1: integer;
    end;

    TOperation = procedure (var data: TOperationData);

    TOperationRecord = packed record
      opcode: byte;
      op: TOperation;
    end;

  procedure doNULL(var data: TOperationData);
  procedure doJE(var data: TOperationData);
  procedure doJG(var data: TOperationData);
  procedure doJL(var data: TOperationData);

  function getOperation(opcode: byte): pointer;

  const
    C_OPERATIONS : array[0 .. C_INSTRUCTION_COUNT - 1] of TOperationRecord = (
      (opcode:$01; op: doNULL), (opcode:$02; op: doNULL), (opcode:$03; op: doNULL),
      (opcode:$04; op: doNULL), (opcode:$05; op: doNULL), (opcode:$06; op: doNULL),
      (opcode:$07; op: doNULL), (opcode:$08; op: doNULL), (opcode:$11; op: doNULL),
      (opcode:$12; op: doNULL), (opcode:$13; op: doNULL), (opcode:$21; op: doNULL),
      (opcode:$22; op: doJE), (opcode:$23; op: doJG), (opcode:$24; op: doJL),
      (opcode:$25; op: doNULL), (opcode:$26; op: doNULL), (opcode:$27; op: doNULL),
      (opcode:$28; op: doNULL), (opcode:$31; op: doNULL), (opcode:$32; op: doNULL),
      (opcode:$33; op: doNULL), (opcode:$34; op: doNULL), (opcode:$41; op: doNULL),
      (opcode:$42; op: doNULL), (opcode:$43; op: doNULL), (opcode:$44; op: doNULL),
      (opcode:$77; op: doNULL)
    );

implementation

  function getConditionCodes(n: integer): integer;
  begin
    if n<>0 then
      if n>0 then
        getConditionCodes := 0
      else
        getConditionCodes := 2
    else
      getConditionCodes := 1;
  end;

  procedure doNULL(var data: TOperationData);
  begin
  end;

  procedure doJE(var data: TOperationData);
  begin
    with data, systemState^ do
      case type0 of
      C_PARAMETER_TYPE_REGISTER: 
        case type1 of
          C_PARAMETER_TYPE_LITERAL: 
            if registers[arg0]=registers[$A] then registers[8]:=3*(arg1-1) else registers[8]:=registers[8]+3;
          C_PARAMETER_TYPE_REGISTER: 
            if registers[arg0]=registers[$A] then registers[8]:=3*(registers[arg1]-1) else registers[8]:=registers[8]+3;
          C_PARAMETER_TYPE_ADDRESS: 
            if registers[arg0]=registers[$A] then registers[8]:=3*(memory[arg1]-1) else registers[8]:=registers[8]+3;
        end;
      C_PARAMETER_TYPE_ADDRESS: 
        case type1 of
          C_PARAMETER_TYPE_LITERAL: 
            if memory[arg0]=registers[$A] then registers[8]:=3*(arg1-1) else registers[8]:=registers[8]+3;
          C_PARAMETER_TYPE_REGISTER: 
            if memory[arg0]=registers[$A] then registers[8]:=3*(registers[arg1]-1) else registers[8]:=registers[8]+3;
          C_PARAMETER_TYPE_ADDRESS: 
            if memory[arg0]=registers[$A] then registers[8]:=3*(memory[arg1]-1) else registers[8]:=registers[8]+3;
        end;
      C_PARAMETER_TYPE_LITERAL:
        case type1 of
          C_PARAMETER_TYPE_LITERAL: 
            if arg0=registers[$A] then registers[8]:=3*(arg1-1) else registers[8]:=registers[8]+3;
          C_PARAMETER_TYPE_REGISTER: 
            if arg0=registers[$A] then registers[8]:=3*(registers[arg1]-1) else registers[8]:=registers[8]+3;
          C_PARAMETER_TYPE_ADDRESS: 
            if arg0=registers[$A] then registers[8]:=3*(memory[arg1]-1) else registers[8]:=registers[8]+3;
        end;
      end;
  end;

  procedure doJG(var data: TOperationData);
  begin
    with data, systemState^ do
      case type0 of
      C_PARAMETER_TYPE_REGISTER: 
      case type1 of
        C_PARAMETER_TYPE_LITERAL: 
          if registers[arg0]>registers[$A] then registers[8]:=3*(arg1-1) else registers[8]:=registers[8]+3;
        C_PARAMETER_TYPE_REGISTER: 
          if registers[arg0]>registers[$A] then registers[8]:=3*(registers[arg1]-1) else registers[8]:=registers[8]+3;
        C_PARAMETER_TYPE_ADDRESS: 
          if registers[arg0]>registers[$A] then registers[8]:=3*(memory[arg1]-1) else registers[8]:=registers[8]+3;
      end;
      C_PARAMETER_TYPE_ADDRESS: 
      case type1 of
        C_PARAMETER_TYPE_LITERAL: 
          if memory[arg0]>registers[$A] then registers[8]:=3*(arg1-1) else registers[8]:=registers[8]+3;
        C_PARAMETER_TYPE_REGISTER: 
          if memory[arg0]>registers[$A] then registers[8]:=3*(registers[arg1]-1) else registers[8]:=registers[8]+3;
        C_PARAMETER_TYPE_ADDRESS: 
          if memory[arg0]>registers[$A] then registers[8]:=3*(memory[arg1]-1) else registers[8]:=registers[8]+3;
      end;
      C_PARAMETER_TYPE_LITERAL: 
      case type1 of
        C_PARAMETER_TYPE_LITERAL: 
          if arg0>registers[$A] then registers[8]:=3*(arg1-1) else registers[8]:=registers[8]+3;
        C_PARAMETER_TYPE_REGISTER: 
          if arg0>registers[$A] then registers[8]:=3*(registers[arg1]-1) else registers[8]:=registers[8]+3;
        C_PARAMETER_TYPE_ADDRESS: 
          if arg0>registers[$A] then registers[8]:=3*(memory[arg1]-1) else registers[8]:=registers[8]+3;
      end;
    end;
  end;

  procedure doJL(var data: TOperationData);
  begin
    with data, systemState^ do
      case type0 of
      C_PARAMETER_TYPE_REGISTER: 
        case type1 of
          C_PARAMETER_TYPE_LITERAL: 
            if registers[arg0]<registers[$A] then registers[8]:=3*(arg1-1) else registers[8]:=registers[8]+3;
          C_PARAMETER_TYPE_REGISTER: 
            if registers[arg0]<registers[$A] then registers[8]:=3*(registers[arg1]-1) else registers[8]:=registers[8]+3;
          C_PARAMETER_TYPE_ADDRESS: 
            if registers[arg0]<registers[$A] then registers[8]:=3*(memory[arg1]-1) else registers[8]:=registers[8]+3;
        end;
      C_PARAMETER_TYPE_ADDRESS: 
        case type1 of
          C_PARAMETER_TYPE_LITERAL: 
            if memory[arg0]<registers[$A] then registers[8]:=3*(arg1-1) else registers[8]:=registers[8]+3;
          C_PARAMETER_TYPE_REGISTER: 
            if memory[arg0]<registers[$A] then registers[8]:=3*(registers[arg1]-1) else registers[8]:=registers[8]+3;
          C_PARAMETER_TYPE_ADDRESS: 
            if memory[arg0]<registers[$A] then registers[8]:=3*(memory[arg1]-1) else registers[8]:=registers[8]+3;
        end;
      C_PARAMETER_TYPE_LITERAL: 
        case type1 of
          C_PARAMETER_TYPE_LITERAL: 
            if arg0<registers[$A] then registers[8]:=3*(arg1-1) else registers[8]:=registers[8]+3;
          C_PARAMETER_TYPE_REGISTER: 
            if arg0<registers[$A] then registers[8]:=3*(registers[arg1]-1) else registers[8]:=registers[8]+3;
          C_PARAMETER_TYPE_ADDRESS: 
            if arg0<registers[$A] then registers[8]:=3*(memory[arg1]-1) else registers[8]:=registers[8]+3;
        end;
      end;
  end;


  function getOperation(opcode: byte): pointer;
  var
    min, max, i: byte;
    currentCode: byte;
  begin
    min := 0;
    max := C_INSTRUCTION_COUNT - 1;
    i := (min + max) div 2;
    currentCode := C_OPERATIONS[i].opcode;
    while (currentCode <> opcode) and (min + 1 <> max) do
    begin
      if currentCode < opcode then min := i else max := i;
      i := (min + max) div 2;
      currentCode := C_OPERATIONS[i].opcode;
    end;
    if currentCode = opcode then 
      getOperation := @C_OPERATIONS[i].op
    else if C_OPERATIONS[max].opcode = opcode then
      getOperation := @C_OPERATIONS[max].op
    else getOperation := nil;
  end;

end.