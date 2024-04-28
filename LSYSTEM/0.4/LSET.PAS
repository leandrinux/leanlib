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
  procedure doJZ(var data: TOperationData);
  procedure doJP(var data: TOperationData);
  procedure doJN(var data: TOperationData);
  procedure doOR(var data: TOperationData);
  procedure doMOV(var data: TOperationData);
  procedure doADD(var data: TOperationData);
  procedure doSUB(var data: TOperationData);
  procedure doMUL(var data: TOperationData);
  procedure doDIV(var data: TOperationData);
  procedure doCMP(var data: TOperationData);
  procedure doJMP(var data: TOperationData);
  procedure doJNZ(var data: TOperationData);
  procedure doAND(var data: TOperationData);
  procedure doNOT(var data: TOperationData);
  procedure doXOR(var data: TOperationData);
  procedure doSTOP(var data: TOperationData);
  procedure doREAD(var data: TOperationData);
  procedure doDUMP(var data: TOperationData);
  procedure doWRITE(var data: TOperationData);
  procedure doLSHIFT(var data: TOperationData);
  procedure doPUSH(var data: TOperationData);
  procedure doPOP(var data: TOperationData);
  procedure doCALL(var data: TOperationData);
  procedure doRET(var data: TOperationData);
  procedure doRSHIFT(var data: TOperationData);

  function getOperation(opcode: byte): pointer;

  const
    C_OPERATIONS : array[0 .. C_INSTRUCTION_COUNT - 1] of TOperationRecord = (
      (opcode:$01; op: doMOV),    (opcode:$02; op: doADD),     (opcode:$03; op: doSUB),
      (opcode:$04; op: doMUL),    (opcode:$05; op: doDIV),     (opcode:$06; op: doCMP),
      (opcode:$07; op: doLSHIFT), (opcode:$08; op: doRSHIFT),  (opcode:$11; op: doREAD),
      (opcode:$12; op: doWRITE),  (opcode:$13; op: doDUMP),    (opcode:$21; op: doJMP),
      (opcode:$22; op: doJE),     (opcode:$23; op: doJG),      (opcode:$24; op: doJL),
      (opcode:$25; op: doJZ),     (opcode:$26; op: doJP),      (opcode:$27; op: doJN),
      (opcode:$28; op: doJNZ),    (opcode:$31; op: doAND),     (opcode:$32; op: doOR),
      (opcode:$33; op: doNOT),    (opcode:$34; op: doXOR),     (opcode:$41; op: doPUSH),
      (opcode:$42; op: doPOP),    (opcode:$43; op: doCALL),    (opcode:$44; op: doRET),
      (opcode:$77; op: doSTOP)
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

 procedure doJZ(var data: TOperationData);
 begin
  with data, systemState^ do
   if (registers[9] and 1) = 1 then
    case type0 of
     C_PARAMETER_TYPE_REGISTER: registers[8]:=3*(registers[arg0]-1);
     C_PARAMETER_TYPE_ADDRESS: registers[8]:=3*(memory[arg0]-1);
     C_PARAMETER_TYPE_LITERAL: registers[8]:=3*(arg0-1);
    end
   else
    registers[8]:=registers[8]+3;
 end;

 procedure doJP(var data: TOperationData);
 begin
  with data, systemState^ do
   if registers[9] and 2=0 then
    case type0 of
     C_PARAMETER_TYPE_REGISTER: registers[8]:=3*(registers[arg0]-1);
     C_PARAMETER_TYPE_ADDRESS: registers[8]:=3*(memory[arg0]-1);
     C_PARAMETER_TYPE_LITERAL: registers[8]:=3*(arg0-1);
    end
   else
    registers[8]:=registers[8]+3;
 end;

 procedure doJN(var data: TOperationData);
 begin
  with data, systemState^ do
   if registers[9] and 2=2 then
    case type0 of
     C_PARAMETER_TYPE_REGISTER: registers[8]:=3*(registers[arg0]-1);
     C_PARAMETER_TYPE_ADDRESS: registers[8]:=3*(memory[arg0]-1);
     C_PARAMETER_TYPE_LITERAL: registers[8]:=3*(arg0-1);
    end
   else
    registers[8]:=registers[8]+3;
 end;

 procedure doOR(var data: TOperationData);
 begin
  with data, systemState^ do
  begin
    case type0 of
    C_PARAMETER_TYPE_REGISTER: begin
           case type1 of
            C_PARAMETER_TYPE_LITERAL: registers[arg0]:=registers[arg0] or arg1;
            C_PARAMETER_TYPE_REGISTER: registers[arg0]:=registers[arg0] or registers[arg1];
            C_PARAMETER_TYPE_ADDRESS: registers[arg0]:=registers[arg0] or memory[arg1];
           end;
           registers[9]:=getConditionCodes(registers[arg0]);
          end;
    C_PARAMETER_TYPE_ADDRESS, C_PARAMETER_TYPE_LITERAL : begin
                  if type0=C_PARAMETER_TYPE_LITERAL then arg0:=ds+arg0; {inmediato como direccion}
                  case type1 of
                   C_PARAMETER_TYPE_LITERAL: memory[arg0]:=memory[arg0] or arg1;
                   C_PARAMETER_TYPE_REGISTER: memory[arg0]:=memory[arg0] or registers[arg1];
                   C_PARAMETER_TYPE_ADDRESS: memory[arg0]:=memory[arg0] or memory[arg1];
                  end;
                  registers[9]:=getConditionCodes(memory[arg0]);
                 end;
    end;
    registers[8]:=registers[8]+3;  {incremento el instruction pointer}
  end;
 end;

 procedure doMOV(var data: TOperationData);
 begin
  with data, systemState^ do
  begin
    case type0 of
    C_PARAMETER_TYPE_REGISTER: case type1 of
           C_PARAMETER_TYPE_LITERAL: registers[arg0]:=arg1;
           C_PARAMETER_TYPE_REGISTER: registers[arg0]:=registers[arg1];
           C_PARAMETER_TYPE_ADDRESS: registers[arg0]:=memory[arg1];
          end;
    C_PARAMETER_TYPE_LITERAL, C_PARAMETER_TYPE_ADDRESS: begin
                 if type0=C_PARAMETER_TYPE_LITERAL then arg0:=ds+arg0; {inmediato como direccion}
                 case type1 of
                  C_PARAMETER_TYPE_LITERAL: memory[arg0]:=arg1;
                  C_PARAMETER_TYPE_REGISTER: memory[arg0]:=registers[arg1];
                  C_PARAMETER_TYPE_ADDRESS: memory[arg0]:=memory[arg1];
                 end;
                end;
    end;
   registers[8]:=registers[8]+3;     {incremento el instruction pointer}
   end;
 end;

 procedure doADD(var data: TOperationData);
 begin
  with data, systemState^ do
  begin
    case type0 of
    C_PARAMETER_TYPE_REGISTER:begin
          case type1 of
           C_PARAMETER_TYPE_LITERAL: registers[arg0]:=registers[arg0]+arg1;
           C_PARAMETER_TYPE_REGISTER: registers[arg0]:=registers[arg0]+registers[arg1];
           C_PARAMETER_TYPE_ADDRESS: registers[arg0]:=registers[arg0]+memory[arg1];
          end;
          registers[9]:=getConditionCodes(registers[arg0]);
         end;
    C_PARAMETER_TYPE_LITERAL, C_PARAMETER_TYPE_ADDRESS: begin
                 if type0=C_PARAMETER_TYPE_LITERAL then arg0:=ds+arg0; {inmediato como direccion}
                 case type1 of
                  C_PARAMETER_TYPE_LITERAL: memory[arg0]:=memory[arg0]+arg1;
                  C_PARAMETER_TYPE_REGISTER: memory[arg0]:=memory[arg0]+registers[arg1];
                  C_PARAMETER_TYPE_ADDRESS: memory[arg0]:=memory[arg0]+memory[arg1];
                 end;
                 registers[9]:=getConditionCodes(memory[arg0]);
                end;
    end;
    registers[8]:=registers[8]+3;     {incremento el instruction pointer}
   end;
 end;

 procedure doSUB(var data: TOperationData);
 begin
  with data, systemState^ do
  begin
    case type0 of
    C_PARAMETER_TYPE_REGISTER:begin
          case type1 of
           C_PARAMETER_TYPE_LITERAL: registers[arg0]:=registers[arg0]-arg1;
           C_PARAMETER_TYPE_REGISTER: registers[arg0]:=registers[arg0]-registers[arg1];
           C_PARAMETER_TYPE_ADDRESS: registers[arg0]:=registers[arg0]-memory[arg1];
          end;
          registers[9]:=getConditionCodes(registers[arg0]);
         end;
    C_PARAMETER_TYPE_LITERAL, C_PARAMETER_TYPE_ADDRESS:begin
                if type0=C_PARAMETER_TYPE_LITERAL then arg0:=ds+arg0; {inmediato como direccion}
                case type1 of
                 C_PARAMETER_TYPE_LITERAL: memory[arg0]:=memory[arg0]-arg1;
                 C_PARAMETER_TYPE_REGISTER: memory[arg0]:=memory[arg0]-registers[arg1];
                 C_PARAMETER_TYPE_ADDRESS: memory[arg0]:=memory[arg0]-memory[arg1];
                end;
                registers[9]:=getConditionCodes(memory[arg0]);
               end;
    end;
    registers[8]:=registers[8]+3;     {incremento el instruction pointer}
   end;
 end;

 procedure doMUL(var data: TOperationData);
 begin
  with data, systemState^ do
  begin
   case type0 of
    C_PARAMETER_TYPE_REGISTER:begin
          case type1 of
           C_PARAMETER_TYPE_LITERAL: registers[arg0]:=registers[arg0]*arg1;
           C_PARAMETER_TYPE_REGISTER: registers[arg0]:=registers[arg0]*registers[arg1];
           C_PARAMETER_TYPE_ADDRESS: registers[arg0]:=registers[arg0]*memory[arg1];
          end;
          registers[9]:=getConditionCodes(registers[arg0]);
         end;
    C_PARAMETER_TYPE_LITERAL, C_PARAMETER_TYPE_ADDRESS: begin
                 if type0=C_PARAMETER_TYPE_LITERAL then arg0:=ds+arg0; {inmediato como direccion}
                 case type1 of
                  C_PARAMETER_TYPE_LITERAL: memory[arg0]:=memory[arg0]*arg1;
                  C_PARAMETER_TYPE_REGISTER: memory[arg0]:=memory[arg0]*registers[arg1];
                  C_PARAMETER_TYPE_ADDRESS: memory[arg0]:=memory[arg0]*memory[arg1];
                 end;
                 registers[9]:=getConditionCodes(memory[arg0]);
                end;
   end;
  registers[8]:=registers[8]+3;     {incremento el instruction pointer}
  end;
 end;

 procedure doDIV(var data: TOperationData);
 begin
  with data, systemState^ do
  begin
   case type0 of
    C_PARAMETER_TYPE_REGISTER:begin
          case type1 of
           C_PARAMETER_TYPE_LITERAL: registers[arg0]:=registers[arg0] div arg1;
           C_PARAMETER_TYPE_REGISTER: registers[arg0]:=registers[arg0] div registers[arg1];
           C_PARAMETER_TYPE_ADDRESS: registers[arg0]:=registers[arg0] div memory[arg1];
          end;
          memory[8]:=getConditionCodes(registers[arg0]);
         end;
    C_PARAMETER_TYPE_LITERAL, C_PARAMETER_TYPE_ADDRESS: begin
                 if type0=C_PARAMETER_TYPE_LITERAL then arg0:=ds+arg0; {inmediato como direccion}
                 case type1 of
                  C_PARAMETER_TYPE_LITERAL: memory[arg0]:=memory[arg0] div arg1;
                  C_PARAMETER_TYPE_REGISTER: memory[arg0]:=memory[arg0] div registers[arg1];
                  C_PARAMETER_TYPE_ADDRESS: memory[arg0]:=memory[arg0] div memory[arg1];
                 end;
                 memory[8]:=getConditionCodes(memory[arg0]);
                end;
   end;
  registers[8]:=registers[8]+3;     {incremento el instruction pointer}
  end;
 end;

 procedure doCMP(var data: TOperationData);
 begin
  with data, systemState^ do
  begin
   case type0 of
    C_PARAMETER_TYPE_REGISTER: case type1 of
           C_PARAMETER_TYPE_LITERAL: registers[9]:=getConditionCodes(registers[arg0]-arg1);
           C_PARAMETER_TYPE_REGISTER: registers[9]:=getConditionCodes(registers[arg0]-registers[arg1]);
           C_PARAMETER_TYPE_ADDRESS: registers[9]:=getConditionCodes(registers[arg0]-memory[arg1]);
          end;
    C_PARAMETER_TYPE_LITERAL, C_PARAMETER_TYPE_ADDRESS: begin
                 if type0=C_PARAMETER_TYPE_LITERAL then arg0:=ds+arg0; {inmediato como direccion}
                 case type1 of
                  C_PARAMETER_TYPE_LITERAL: registers[9]:=getConditionCodes(memory[arg0]-arg1);
                  C_PARAMETER_TYPE_REGISTER: registers[9]:=getConditionCodes(memory[arg0]-registers[arg1]);
                  C_PARAMETER_TYPE_ADDRESS: registers[9]:=getConditionCodes(memory[arg0]-memory[arg1]);
                 end;
                end;
   end;
  registers[8]:=registers[8]+3;     {incremento el instruction pointer}
  end;
 end;

 procedure doJMP(var data: TOperationData);
 begin
  with data, systemState^ do
   case type0 of
    C_PARAMETER_TYPE_LITERAL: registers[8]:=3*(arg0-1);
    C_PARAMETER_TYPE_REGISTER: registers[8]:=3*(registers[arg0]-1);
    C_PARAMETER_TYPE_ADDRESS: registers[8]:=3*(memory[arg0]-1);
   end;
 end;

 procedure doJNZ(var data: TOperationData);
 begin
  with data, systemState^ do
   if registers[9] and 1=0 then
    case type0 of
     C_PARAMETER_TYPE_LITERAL: registers[8]:=3*(arg0-1);
     C_PARAMETER_TYPE_REGISTER: registers[8]:=3*(registers[arg0]-1);
     C_PARAMETER_TYPE_ADDRESS: registers[8]:=3*(memory[arg0]-1);
    end
   else
     registers[8]:=registers[8]+3;
 end;

 procedure doAND(var data: TOperationData);
 begin
  with data, systemState^ do
  begin
   case type0 of
    C_PARAMETER_TYPE_REGISTER: begin
           case type1 of
            C_PARAMETER_TYPE_LITERAL: registers[arg0]:=registers[arg0] and arg1;
            C_PARAMETER_TYPE_REGISTER: registers[arg0]:=registers[arg0] and registers[arg1];
            C_PARAMETER_TYPE_ADDRESS: registers[arg0]:=registers[arg0] and memory[arg1];
           end;
           registers[9]:=getConditionCodes(registers[arg0]);
          end;
    C_PARAMETER_TYPE_ADDRESS, C_PARAMETER_TYPE_LITERAL : begin
                  if type0=C_PARAMETER_TYPE_LITERAL then arg0:=ds+arg0; {inmediato como direccion}
                  case type1 of
                   C_PARAMETER_TYPE_LITERAL: memory[arg0]:=memory[arg0] and arg1;
                   C_PARAMETER_TYPE_REGISTER: memory[arg0]:=memory[arg0] and registers[arg1];
                   C_PARAMETER_TYPE_ADDRESS: memory[arg0]:=memory[arg0] and memory[arg1];
                  end;
                  registers[9]:=getConditionCodes(memory[arg0]);
                 end;
   end;
  registers[8]:=registers[8]+3;  {incremento el instruction pointer}
  end;
 end;

 procedure doNOT(var data: TOperationData);
 begin
  with data, systemState^ do
  begin
   case type0 of
    C_PARAMETER_TYPE_REGISTER:begin
          registers[arg0]:=not registers[arg0];
          registers[9]:=getConditionCodes(registers[arg0]);
         end;
    C_PARAMETER_TYPE_LITERAL, C_PARAMETER_TYPE_ADDRESS: begin
                 if type0=C_PARAMETER_TYPE_LITERAL then arg0:=ds+arg0; {inmediato como direccion}
                 memory[arg0]:=not memory[arg0];
                 registers[9]:=getConditionCodes(memory[arg0]);
                end;
   end;
  registers[8]:=registers[8]+3;     {incremento el instruction pointer}
  end;
 end;

 procedure doXOR(var data: TOperationData);
 begin
  with data, systemState^ do
  begin
   case type0 of
    C_PARAMETER_TYPE_REGISTER: begin
           case type1 of
            C_PARAMETER_TYPE_LITERAL: registers[arg0]:=registers[arg0] xor arg1;
            C_PARAMETER_TYPE_REGISTER: registers[arg0]:=registers[arg0] xor registers[arg1];
            C_PARAMETER_TYPE_ADDRESS: registers[arg0]:=registers[arg0] xor memory[arg1];
           end;
           registers[9]:=getConditionCodes(registers[arg0]);
          end;
    C_PARAMETER_TYPE_ADDRESS, C_PARAMETER_TYPE_LITERAL : begin
                  if type0=C_PARAMETER_TYPE_LITERAL then arg0:=ds+arg0; {inmediato como direccion}
                  case type1 of
                   C_PARAMETER_TYPE_LITERAL: memory[arg0]:=memory[arg0] xor arg1;
                   C_PARAMETER_TYPE_REGISTER: memory[arg0]:=memory[arg0] xor registers[arg1];
                   C_PARAMETER_TYPE_ADDRESS: memory[arg0]:=memory[arg0] xor memory[arg1];
                  end;
                  registers[9]:=getConditionCodes(memory[arg0]);
                 end;
   end;
  registers[8]:=registers[8]+3;  {incremento el instruction pointer}
  end;
 end;

 procedure doSTOP(var data: TOperationData);
 begin
  with data.systemState^ do registers[8] := ds;
 end;

 procedure doREAD(var data: TOperationData);
 var
  a,b,i:word;
 begin
  a:=0; b:=0;
  with data, systemState^ do
  begin
   case type0 of
    C_PARAMETER_TYPE_LITERAL     :a:=arg0+ds;
    C_PARAMETER_TYPE_ADDRESS     :a:=arg0;
    C_PARAMETER_TYPE_REGISTER     :a:=registers[arg0]+ds;
   end;
   case type1 of
    C_PARAMETER_TYPE_LITERAL     :b:=arg1+ds;
    C_PARAMETER_TYPE_ADDRESS     :b:=arg1;
    C_PARAMETER_TYPE_REGISTER     :b:=registers[arg1]+ds;
   end;
   for i:=a to b do
   begin
    write('[');
    writeDecAddress(i-ds);
    write('] ?');
    readln(memory[i]);
   end;
   registers[8]:=registers[8]+3;     {incremento el instruction pointer}
  end;
 end;

 procedure doWRITE(var data: TOperationData);
 var
  a,b,i:word;
 begin
  a:=0; b:=0;
  with data, systemState^ do
  begin
   case type0 of
    C_PARAMETER_TYPE_LITERAL     :a:=arg0+ds;
    C_PARAMETER_TYPE_ADDRESS     :a:=arg0;
    C_PARAMETER_TYPE_REGISTER     :a:=registers[arg0]+ds;
   end;
   case type1 of
    C_PARAMETER_TYPE_LITERAL     :b:=arg1+ds;
    C_PARAMETER_TYPE_ADDRESS     :b:=arg1;
    C_PARAMETER_TYPE_REGISTER     :b:=registers[arg1]+ds;
   end;
   for i:=a to b do
   begin
    write ('[');
    writeDecAddress(i-ds);
    writeln('] ', memory[i], #9, wordTohex(memory[i]));
   end;
   registers[8]:=registers[8]+3;     {incremento el instruction pointer}
  end;
 end;

 procedure doDUMP(var data: TOperationData);
 var
  i:byte;
 begin
  with data, systemState^ do
  begin
   writeln('[IP]   ', registers[8], #9, wordToHex(registers[8]));
   writeln('[CC]   ', registers[9], #9, wordTohex(registers[9]));
   for i:=$A to $F do
     writeln('[', chr(55+i), 'X]   ', registers[i], #9, wordTohex(registers[i]));
   dowrite(data);
  end;
 end;

 procedure doLSHIFT(var data: TOperationData);
 var a:integer;
 begin
  with data, systemState^ do
  begin
   case type0 of
    C_PARAMETER_TYPE_REGISTER:begin
          case type1 of
           C_PARAMETER_TYPE_LITERAL: for a:=1 to arg1 do registers[arg0]:=registers[arg0] shl 1;
           C_PARAMETER_TYPE_REGISTER: for a:=1 to registers[arg1] do registers[arg0]:=registers[arg0] shl 1;
           C_PARAMETER_TYPE_ADDRESS: for a:=1 to memory[arg1] do registers[arg0]:=registers[arg0] shl 1;
          end;
          registers[9]:=getConditionCodes(registers[arg0]);
         end;
    C_PARAMETER_TYPE_LITERAL, C_PARAMETER_TYPE_ADDRESS:begin
                if type0=C_PARAMETER_TYPE_LITERAL then arg0:=ds+arg0; {inmediato como direccion}
                case type1 of
                 C_PARAMETER_TYPE_LITERAL: for a:=1 to arg1 do memory[arg0]:=memory[arg0] shl 1;
                 C_PARAMETER_TYPE_REGISTER: for a:=1 to registers[arg1] do memory[arg0]:=memory[arg0] shl 1;
                 C_PARAMETER_TYPE_ADDRESS: for a:=1 to memory[arg1] do memory[arg0]:=memory[arg0] shl 1;
                end;
                registers[9]:=getConditionCodes(memory[arg0]);
               end;
   end;
  registers[8]:=registers[8]+3;     {incremento el instruction pointer}
  end;
 end;

 procedure doRSHIFT(var data: TOperationData);
 var a:integer;
 begin
  with data, systemState^ do
  begin
   case type0 of
    C_PARAMETER_TYPE_REGISTER:begin
          case type1 of
           C_PARAMETER_TYPE_LITERAL: for a:=1 to arg1 do registers[arg0]:=registers[arg0] shr 1;
           C_PARAMETER_TYPE_REGISTER: for a:=1 to registers[arg1] do registers[arg0]:=registers[arg0] shr 1;
           C_PARAMETER_TYPE_ADDRESS: for a:=1 to memory[arg1] do registers[arg0]:=registers[arg0] shr 1;
          end;
          registers[9]:=getConditionCodes(registers[arg0]);
         end;
    C_PARAMETER_TYPE_LITERAL, C_PARAMETER_TYPE_ADDRESS:begin
                if type0=C_PARAMETER_TYPE_LITERAL then arg0:=ds+arg0; {inmediato como direccion}
                case type1 of
                 C_PARAMETER_TYPE_LITERAL: for a:=1 to arg1 do memory[arg0]:=memory[arg0] shr 1;
                 C_PARAMETER_TYPE_REGISTER: for a:=1 to registers[arg1] do memory[arg0]:=memory[arg0] shr 1;
                 C_PARAMETER_TYPE_ADDRESS: for a:=1 to memory[arg1] do memory[arg0]:=memory[arg0] shr 1;
                end;
                registers[9]:=getConditionCodes(memory[arg0]);
               end;
   end;
  registers[8]:=registers[8]+3;     {incremento el instruction pointer}
  end;
 end;

 procedure doPUSH(var data: TOperationData);
 begin
  with data, systemState^ do
  begin
   dec(registers[6]);
   if registers[6]<0 then
   begin
    writeln(' > ERROR!: Desbordamiento de pila.');
    registers[8]:=ds; {detengo la ejecuci�n}
   end else
   begin
    case type0 of
     C_PARAMETER_TYPE_LITERAL:memory[ss+registers[6]]:=arg0;
     C_PARAMETER_TYPE_REGISTER:memory[ss+registers[6]]:=registers[arg0];
     C_PARAMETER_TYPE_ADDRESS:memory[ss+registers[6]]:=memory[arg0];
    end;
    registers[8]:=registers[8]+3;     {incremento el instruction pointer}
   end;
  end;
 end;

 procedure doPOP(var data: TOperationData);
 begin
  with data, systemState^ do
  begin
   if registers[6]=2000-SS then
   begin
    writeln(' > ERROR!: Pila vacia.');
    registers[8]:=ds; {detengo la ejecuci�n}
   end else
   begin
    case type0 of
     C_PARAMETER_TYPE_LITERAL:memory[ds+arg0]:=memory[ss+registers[6]]; {considerado como direccion}
     C_PARAMETER_TYPE_REGISTER:registers[arg0]:=memory[ss+registers[6]];
     C_PARAMETER_TYPE_ADDRESS:memory[arg0]:=memory[ss+registers[6]];
    end;
    inc(registers[6]);
    registers[8]:=registers[8]+3;     {incremento el instruction pointer}
   end;
  end;
 end;

 procedure doCALL(var data: TOperationData);
 var 
   aux: TOperationData;
 begin
  aux.systemState := data.systemState;
  aux.arg0 := data.systemState^.registers[8]+3;
  aux.type0 := C_PARAMETER_TYPE_LITERAL;
  doPUSH(aux);
  doJMP(data);
 end;

 procedure doRET(var data: TOperationData);
 var 
   aux: TOperationData;
 begin
   aux.systemState := data.systemState;
   data.arg0 := 8;
   data.type0 := C_PARAMETER_TYPE_REGISTER;
   doPOP(aux);
   with data.systemState^ do registers[8] := registers[8] - 3; {correcci�n del IP debido a POP lo avanzó}
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