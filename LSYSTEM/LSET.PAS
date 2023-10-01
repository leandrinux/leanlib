unit
  lset;

interface

  uses
    lcommon;

  type
    TOperationData = packed record
      systemState: PSystemState;
      arg0,arg1: integer;
      type0,type1: byte;
    end;

    TOperation = procedure (var data: TOperationData);

    TOperationRecord = packed record
      code: byte;
      op: TOperation;
    end;

  procedure doNULL(var data: TOperationData);

  const
    C_OPERATIONS : array[0..C_INSTRUCTION_COUNT-1] of TOperationRecord = (
      (code:$01; op: doNULL), (code:$02; op: doNULL), (code:$03; op: doNULL),
      (code:$04; op: doNULL), (code:$05; op: doNULL), (code:$06; op: doNULL),
      (code:$07; op: doNULL), (code:$08; op: doNULL), (code:$11; op: doNULL),
      (code:$12; op: doNULL), (code:$13; op: doNULL), (code:$21; op: doNULL),
      (code:$22; op: doNULL), (code:$23; op: doNULL), (code:$24; op: doNULL),
      (code:$25; op: doNULL), (code:$26; op: doNULL), (code:$27; op: doNULL),
      (code:$28; op: doNULL), (code:$31; op: doNULL), (code:$32; op: doNULL),
      (code:$33; op: doNULL), (code:$34; op: doNULL), (code:$41; op: doNULL),
      (code:$42; op: doNULL), (code:$43; op: doNULL), (code:$44; op: doNULL),
      (code:$77; op: doNULL)
    );

implementation

  procedure doNULL(var data: TOperationData);
  begin
  end;

end.