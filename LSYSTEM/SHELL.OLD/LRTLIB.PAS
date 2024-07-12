unit
  lrtlib;

interface

  uses
    lcommon, lset;

  procedure runFile(filename: string);

implementation

  procedure run(var systemState: TSystemState);
  var
    opcode: byte;
    operation: pointer;
    instruction: PInstruction;
    operationData: TOperationData;
  begin
    operationData.systemState := @systemState;
    with systemState do
    begin
      registers[8] := 0;
      while registers[8] < ds do { program execution cycle }
      begin
        instruction := @memory[registers[8]];
        opcode := instruction^.opcode shr 8;
        operation := getOperation(opcode);
        if operation = nil then
        begin
          writeln(' > Unknown instruction!');
          registers[8] := registers[8] + 3; { skip instruction }
        end else begin
          with operationData do
          begin
            arg0 := instruction^.param0;
            arg1 := instruction^.param1;
            type0 := (instruction^.opcode and $000C) shr 2;
            type1 := instruction^.opcode and $0003;
            { update memory parameters from logical to absolute addresses }
            if type0 = C_PARAMETER_TYPE_ADDRESS then inc(arg0, DS);
            if type1 = C_PARAMETER_TYPE_ADDRESS then inc(arg1, DS);
            { update indirect parameters to absolute addresses }
            if type0 = C_PARAMETER_TYPE_INDIRECT then updateIndirect(arg0, type0, systemState^);
            if type1 = C_PARAMETER_TYPE_INDIRECT then updateIndirect(arg1, type1, systemState^);
          end;  
          TOperation(operation)(operationData)
        end;
      end;
      { end execution loop }
    end;
  end;

  procedure runFile(filename: string);
  var
    systemState: TSystemState;
  begin
    loadState(systemState, filename);
    run(systemState);
  end;
  
end.