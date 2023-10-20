unit 
  lbin;

interface

  uses
    lcommon;

  {$P+} { enables compatibility between strings of different type }

  const
    C_DELIMITERS: set of char = [' ', ',', ':', #9];

  type
    EParameterType = (
      EParameterTypeInmediate,
      EParameterTypeSymbol,
      EParameterTypeAddress,
      EParameterTypeRegister,
      EParameterTypeIndirect,
      EParameterTypeEmpty,
      EParameterTypeInvalid
    );
   
    { Pending symbols list }
    PPendingSymbolNode = ^TPendingSymbolNode;
    TPendingSymbolNode = record
        position: TMemoryAddress;
        next: PPendingSymbolNode;
    end;

    { Symbols list }
    TSymbolId = TString10;

    PSymbolNode = ^TSymbolNode;

    TSymbolNode = record
        id: TSymbolId;
        value: integer;
        pendingList: PPendingSymbolNode;
        next: PSymbolNode;
    end;

    TOpcodeId = string[6];

    TRegisterName = string[2];

    TParameterStr = string[20];

    TOpcodeData = packed record
      code: byte;
      args: byte;      
      id: TOpcodeId;
    end;

  const
    C_INSTRUCTION_SET : array[0..C_INSTRUCTION_COUNT-1] of TOpcodeData = (
      (code:$02; args:2; id:'ADD'),  (code:$31; args:2; id:'AND'),  (code:$43; args:1; id:'CALL'),
      (code:$06; args:2; id:'CMP'),  (code:$05; args:2; id:'DIV'),  (code:$13; args:0; id:'DUMP'),
      (code:$22; args:2; id:'JE'),   (code:$23; args:2; id:'JG'),   (code:$24; args:2; id:'JL'),
      (code:$21; args:1; id:'JMP'),  (code:$27; args:1; id:'JN'),   (code:$28; args:1; id:'JNZ'),
      (code:$26; args:1; id:'JP'),   (code:$25; args:1; id:'JZ'),   (code:$07; args:2; id:'LSHIFT'),
      (code:$01; args:2; id:'MOV'),  (code:$04; args:2; id:'MUL'),  (code:$33; args:1; id:'NOT'),
      (code:$32; args:2; id:'OR'),   (code:$42; args:1; id:'POP'),  (code:$41; args:1; id:'PUSH'),
      (code:$11; args:2; id:'READ'), (code:$44; args:0; id:'RET'),  (code:$08; args:2; id:'RSHIFT'),
      (code:$77; args:0; id:'STOP'), (code:$03; args:2; id:'SUB'),  (code:$12; args:2; id:'WRITE'),
      (code:$34; args:2; id:'XOR')
    );

    C_PARAMETER_TYPES: array[EParameterType] of string[9] = (
      'inmediate', 'symbol', 'address', 'register', 'indirect', 'empty', 'invalid'
    );

    C_REGISTER_COUNT = 10;
    C_REGISTERS: array[0..C_REGISTER_COUNT-1] of TRegisterName = (
      'SP', 'BP', 'IP', 'CC', 'AX', 'BX', 'CX', 'DX', 'EX', 'FX'
    );

  function addToSymbolList(var list: PSymbolNode; const id: TSymbolId; value: integer): PSymbolNode;
  function findSymbolNodeWithId(const symbolList: PSymbolNode; const id: TSymbolId): PSymbolNode;
  procedure getOpcodeDataById(const id: TOpcodeId; var data: TOpcodeData);
  procedure getOpcodeDataByCode(code: byte; var data: TOpcodeData);
  function getParameterAsString(parameterType: byte; parameterValue: integer): TParameterStr;
  procedure extractToken(var input:string; var token:string);
  function getParameterType(parameter: string): EParameterType;
  function getParameterTypeCode(parameterType: EParameterType; var parameterCode: byte): boolean;
  procedure addPendingValue(var pendingList: PPendingSymbolNode; value: integer);
  procedure clearPendingList(var symbolNode: PSymbolNode; var systemState: TSystemState);
  function getRegisterValue(const registerName: TRegisterName; var registerValue: byte): boolean;
  function compileInstruction( 
    const line: string; 
    var systemState: TSystemState;
    var symbolList: PSymbolNode; 
    var lineNumber: word
  ): boolean;
  function instructionToText(const instruction: TInstruction): string;
  function build(const sourceFilename, binaryFilename: string): boolean;

implementation

  function getRegisterValue(const registerName: TRegisterName; var registerValue: byte): boolean;
  var
    i: byte;
  begin
    getRegisterValue := true;
    i := 0;
    while (i < C_REGISTER_COUNT) and (C_REGISTERS[i] <> registerName) do inc(i);
    if i = C_REGISTER_COUNT then
      getRegisterValue := false
    else
      registerValue := i + 6;
  end;

  function getParameterTypeCode(parameterType: EParameterType; var parameterCode: byte): boolean;
  begin
    getParameterTypeCode := true;
    case parameterType of
      EParameterTypeInmediate, EParameterTypeSymbol: 
        parameterCode := C_PARAMETER_TYPE_LITERAL;
      EParameterTypeAddress:
        parameterCode := C_PARAMETER_TYPE_ADDRESS;
      EParameterTypeRegister:
        parameterCode := C_PARAMETER_TYPE_REGISTER;
      EParameterTypeIndirect:
        parameterCode := C_PARAMETER_TYPE_INDIRECT;
    else
      parameterCode := 0;
      getParameterTypeCode := false;
    end;
  end;

  {
    receives the list of symbols and a symbol identifier and returns pointer where a symbol is stored or nil if not found
  }
  function findSymbolNodeWithId(const symbolList: PSymbolNode; const id: TSymbolId): PSymbolNode;
  var
    node: PSymbolNode;
  begin
    node := symbolList;
    findSymbolNodeWithId := nil;
    if node <> nil then
    begin
      while (node<>nil) and (node^.id < id) do node := node^.next;
      if (node<>nil) and (node^.id = id) then findSymbolNodeWithId := node;
    end;
  end;

  { adds an element to the symbols list }
  function addToSymbolList(var list: PSymbolNode; const id: TSymbolId; value: integer): PSymbolNode;
  var 
    nnode, current, previous: PSymbolNode;
  begin
    new(nnode);
    nnode^.id := id; 
    nnode^.value := value; 
    nnode^.pendingList := nil; 
    nnode^.next := nil; 
    
    if list = nil then
    begin
      list := nnode;
    end else
    begin
      previous := nil;
      current := list;
      while (current <> nil) and (nnode^.id > current^.id) do
      begin
        previous := current;
        current := current^.next;
      end;
      nnode^.next := current;
      if previous = nil then
        list := nnode
      else
        previous^.next := nnode;
    end;
    addToSymbolList := nnode;
  end;

  { gets a instruction identifier and returns the matching opcode }
  procedure getOpcodeDataById(const id: TOpcodeId; var data: TOpcodeData);
  var
    min, max, i: byte;
    current: TOpcodeId;
  begin
    min := 0;
    max := C_INSTRUCTION_COUNT - 1;
    i := (min + max) div 2;
    current := C_INSTRUCTION_SET[i].id;
    while (current <> id) and (min + 1 <> max) do
    begin
      if current < id then min := i else max := i;
      i := (min + max) div 2;
      current := C_INSTRUCTION_SET[i].id;
    end;
    if current = id then 
      data := C_INSTRUCTION_SET[i]
    else if C_INSTRUCTION_SET[max].id = id then
      data := C_INSTRUCTION_SET[max]
    else 
      data.code := C_INVALID_OPCODE;
  end;

  { returns the name of the operation for the specified opcode }
  procedure getOpcodeDataByCode(code: byte; var data: TOpcodeData);
  var
    i: byte;
  begin
    i := 0;
    while (i < C_INSTRUCTION_COUNT) and (C_INSTRUCTION_SET[i].code <> code) do inc(i);
    if i = C_INSTRUCTION_COUNT then
    begin
      data.code := code;
      data.args := 0;
      data.id := C_INVALID_OPCODE_ID;
    end else
      data := C_INSTRUCTION_SET[i];
  end;

  function getParameterAsString(parameterType: byte; parameterValue: integer): TParameterStr;
  var
    returnValue: TParameterStr;
    constantValue: shortInt;
  begin
    returnValue := '';
    case parameterType of

      C_PARAMETER_TYPE_LITERAL: 
        returnValue := '$' + wordToHex(parameterValue);

      C_PARAMETER_TYPE_ADDRESS: 
        returnValue := wordToDec(parameterValue);

      C_PARAMETER_TYPE_REGISTER: 
        returnValue := C_REGISTERS[parameterValue - 6];

      C_PARAMETER_TYPE_INDIRECT: 
      begin
        returnValue := '[' + C_REGISTERS[(parameterValue and $000F) - 6] + ']';
        constantValue := parameterValue shr 8;
        if constantValue > 0 then 
          returnValue := returnValue + '+' + shortintToDec(constantValue)
        else if constantValue < 0 then 
          returnValue := returnValue + shortintToDec(constantValue);
      end;

    end;
    getParameterAsString := returnValue;
  end;

  { extracts a token from the input string, removing it and returning it as output }
  procedure extractToken(var input:string; var token:string);
  var
    i, l: byte;
  begin
    token := '';
    i := 1; 
    l := length(input);
    while (i <= l) and (input[i] in C_DELIMITERS) do i := i + 1;
    while (i <= l) and not (input[i] in C_DELIMITERS) do
    begin
      token := token + input[i];
      i := i + 1;
    end;
    delete(input, 1, i - 1);
  end;

  { gets a string with a valid parameter and returns its type }
  function getParameterType(parameter: string): EParameterType;
  begin
    getParameterType := EParameterTypeInvalid;
    if parameter = '' then
      getParameterType := EParameterTypeEmpty
    else
      case parameter[1] of
        '@', '#': getParameterType := EParameterTypeInmediate;
        '$': if isValidHexNumber(copy(parameter, 2, length(parameter) - 1)) then
               getParameterType := EParameterTypeInmediate
             else
               getParameterType := EParameterTypeSymbol;
        '0'..'9': getParameterType := EParameterTypeAddress;
        '[': getParameterType := EParameterTypeIndirect;
        'A'..'Z': if isValidRegister(parameter) then
                    getParameterType := EParameterTypeRegister
                  else
                    getParameterType := EParameterTypeSymbol;
      end;
  end;

  { adds an absolute memory value to the pending list }
  procedure addPendingValue(var pendingList: PPendingSymbolNode; value: integer);
  var 
    node: PPendingSymbolNode;
  begin
    new(node);
    node^.position := value;
    if pendingList <> nil then
      node^.next := pendingList
    else
      node^.next := nil;
    pendingList := node;
  end;

  { gets a symbol node and clears all its pending nodes by replacing in the memory structure }
  procedure clearPendingList(var symbolNode: PSymbolNode; var systemState: TSystemState);
  var 
    aux: PPendingSymbolNode;
  begin
    with symbolNode^ do
      while pendingList <> nil do
      begin
        systemState.memory[pendingList^.position] := symbolNode^.value;
        aux := pendingList^.next;
        dispose(pendingList);
        pendingList := aux;
      end;
  end;

  procedure parseLiteral(const token: string; var paramType, paramValue: integer);
  begin
    paramType := C_PARAMETER_TYPE_LITERAL;
    paramValue := strToInt(token);
  end;

  procedure parseSymbol(
    const token: string; 
    var paramType, paramValue: integer; 
    var symbolList: PSymbolNode; 
    var systemState: TSystemState;
    paramAddress: integer
  );
  var
    node: PSymbolNode;
  begin
    paramType := C_PARAMETER_TYPE_LITERAL;
    node := findSymbolNodeWithId(symbolList, token);
    if node = nil then
    begin
      node := addToSymbolList(symbolList, token, -1);
      addPendingValue(node^.pendingList, paramAddress);
      paramValue := -1;
    end else
      { if there's no pending list, then the symbol value is already set }
      if node^.pendingList = nil then
        paramValue := node^.value
      else begin
        addPendingValue(node^.pendingList, paramAddress);
        paramValue := -1;
      end;  
  end;

  procedure parseAddress(const token: string; var paramType, paramValue: integer);
  begin
    paramType := C_PARAMETER_TYPE_ADDRESS;
    paramValue := decToInt(token);
  end;

  procedure parseRegister(const token: string; var paramType, paramValue: integer);
  begin
    paramType := C_PARAMETER_TYPE_REGISTER;
    if token[2] = 'X' then
      paramValue := hexToInt(token[1])
    else
      if token[2] = 'P' then
        case token[1] of
          'S': paramValue := 6;
          'I': paramValue := 8;
          'B': paramValue := 7;
        end
    else
      if token[1] = 'CC' then
        paramValue := 9;
  end;

  procedure parseIndirect(var token: string; var paramType, paramValue: integer; const lineCopy: string);
  var
    b: byte;
    decstr: string;
    constantValue: integer;
    registerName: TRegisterName;  
    registerValue: byte;  
  begin
    paramType := C_PARAMETER_TYPE_INDIRECT;
    paramValue := 0;

    { we get the code for the specified register }
    registerName := token[2] + token[3];
    strUpper(registerName);
    if not getRegisterValue(registerName, registerValue) then exit;

    { if there is a constant present then we get its value }
    token := token + lineCopy;
    b := pos(',', token);
    if b<>0 then delete(token, b, ord(token[0])-b+1);
    delete(token, 1, 4);
    extractToken(token, decstr);
    if decstr = '' then
      constantValue := 0
    else begin
      constantValue := 1;
      if decstr[1] in ['+', '-'] then
      begin
        if decstr[1] = '-' then constantValue := -1;
        delete(decstr, 1, 1);
      end;
      constantValue := (constantValue * decToInt(decstr)) shl 4;
    end;
    { we form the value for this parameter and assign it }
    paramValue := constantValue or registerValue;
  end;

  {
    receives:
      - a line of text representing a sentence to be compiled
      - the system state
      - the full list of symbols
      - the current line number
    returns true is compilation was successful, otherwise returns false
  }
  function compileInstruction( 
    const line: string; 
    var systemState: TSystemState;
    var symbolList: PSymbolNode; 
    var lineNumber: word
  ): boolean;
  var
    parameters: array[1..2] of string;
    types: array[1..2] of integer;
    command: TString10; 
    lineCopy, aux: string;  
    opcodeData: TOpcodeData;
    parameterValue: ^integer;
    i: byte;
    instruction: TInstruction;
    node: PSymbolNode;
  begin
    compileInstruction := true;
    lineCopy := line;
    extractToken(lineCopy, command);
    if command[1] = '*' then
      writeln(line) { line is a comment - outputs it to console }
    else begin
      strUpper(command);
      strupper(lineCopy);
      { first I'll check for the presence of a label or a command }
      if pos(':', line) <> 0 then
      begin
        { this line has a label and it is stored in the command variable }
        node := findSymbolNodeWithId(symbolList, command);
        if node <> nil then
        begin
          if node^.pendingList = nil then
          begin
            writeln('> ERROR: Symbol "', command, '" is being redefined.');
            compileInstruction := false;
          end else
          begin
            { this label was used before and now we clear its pending list }
            node^.value := lineNumber + 1;
            clearPendingList(node, systemState);
          end;
        end else
          addToSymbolList(symbolList, command, lineNumber + 1); { we are defining a new label symbol }
        extractToken(lineCopy, command);
      end;
     { there's no label, so I'll continue. }
     { Identify the command and search for its opcode }
     getOpcodeDataById(command, opcodeData);
     if opcodeData.code = C_INVALID_OPCODE then
     begin
       instruction := C_NULL_INSTRUCTION;
       writeln('> ERROR: Invalid opcode ("', command, '")');
       compileInstruction := false;
     end else begin
       { fill up the instruction record }
       for i := 1 to 2 do
       begin

         if i = 1 then 
           parameterValue := @instruction.param0
         else
           parameterValue := @instruction.param1;

         extractToken(lineCopy, parameters[i]);
         if parameters[i] <> '' then
         begin
           aux := parameters[i];
           case getParameterType(aux) of
             EParameterTypeInmediate:
               parseLiteral(parameters[i], types[i], parameterValue^);
      
             EParameterTypeSymbol:
               parseSymbol(parameters[i], types[i], parameterValue^, symbolList, systemState, systemState.ds + i);

             EParameterTypeAddress: 
               parseAddress(parameters[i], types[i], parameterValue^);
             
             EParameterTypeRegister: 
               parseRegister(parameters[i], types[i], parameterValue^);
             
             EParameterTypeIndirect:
               parseIndirect(parameters[i], types[i], parameterValue^, lineCopy);
           end;
         end else begin 
           { if parameter doesn't exist then assign default values }
           parameterValue^ := 0;
           types[i] := 0;
         end
       end; { end of parameter for cycle }
       instruction.opcode := (opcodeData.code shl 8) or (types[1] shl 2) or types[2];
     end;
     lineNumber := lineNumber + 1;
     with systemState, instruction do
     begin
       writeln('[', wordToHex(DS), ']  ', wordToHex(opcode), ' ',
         wordToHex(param0),' ', wordToHex(param1), lineNumber:5, ':', line
       );
       memory[ds] := opcode;
       memory[ds+1] := param0;
       memory[ds+2] := param1;
       ds := ds + 3;
     end;
   end;
  end;

{ gets an open text file, symbol list and system state }
{ returns an error code }
  function readHeader(var textFile: Text; var symbolList: PSymbolNode; var systemState: TSystemState): EErrorCode;
  var
    line, lineCopy, token:string;
    b: byte;
    errorCode: EErrorCode;
  begin
    errorCode := EErrorNone;
    readln(textFile, lineCopy);
    line := lineCopy;
    extractToken(line, token);
    while (errorCode <> EErrorFatal) and (token[1] <> '\') do
    begin
      if token[1] = '*' then
        writeln(lineCopy)
      else begin
        strUpper(line);
        if (line <> '') and ( pos('EQU', line) <> 0) then
        begin
          strUpper(token);
          { we'll include a constant into the symbols list }
          if findSymbolNodeWithId(symbolList, token) <> nil then
          begin
            errorCode := EErrorWarning;
            writeln('> WARNING: Constant identifier redefined');
          end else begin
            while not (line[1] in ['@','#','$']) do delete(line, 1, 1);
            addToSymbolList(symbolList, token, strToInt(line));
          end;
        end;
      end;
      readln(textFile, lineCopy);
      if not seekEOF(textFile) then
      begin
        line := lineCopy;
        extractToken(line, token);
      end else
        errorCode := EErrorFatal;
    end;
    if errorCode <> EErrorFatal then
    begin
      {now we'll process the \\asm line }
      while (line<>'') and not (line[1] in ['0'..'9']) do delete(line, 1, 1);
      with systemState do
      begin
        if line = '' then
        begin
          registers[6] := C_DEFAULT_STACK_SIZE { move SP to memory position 200 (default) };
        end else begin
          registers[6] := decToInt(line);
        end;
        ss := C_DEFAULT_MEMORY_SIZE - registers[6];
      end;
    end;
    readHeader := errorCode;
  end;

  { gets a symbol list and returns true if all symbols are defined, otherwise false }
  function listAndCleanSymbols(var symbolList: PSymbolNode): boolean;
  var
    symbolNode: PSymbolNode; 
    pendingNode: PPendingSymbolNode;
  begin
    writeln; 
    writeln(' > Symbols list:');
    listAndCleanSymbols := true;
    while symbolList <> nil do
    begin
      if symbolList^.pendingList = nil then
        writeln('   ', symbolList^.id, ' = ', symbolList^.value)
      else begin
        listAndCleanSymbols := false;
        writeln(' > ERROR: Symbol "', symbolList^.id, '" is undefined.');
        while symbolList^.pendingList <> nil do
        begin
          pendingNode := symbolList^.pendingList^.next;
          dispose(symbolList^.pendingList);
          symbolList^.pendingList := pendingNode;
        end;
      end;
      symbolNode := symbolList^.next;
      dispose(symbolList);
      symbolList := symbolNode;
    end;
  end;

  function instructionToText(const instruction: TInstruction): string;
  var
    opcodeData: TOpcodeData;
    returnValue: string;
  begin
    with instruction, opcodeData do
    begin
      getOpcodeDataByCode(opcode shr 8, opcodeData);
      returnValue := id;
      if args>0 then
      begin
        returnValue := returnValue + ' ' + getParameterAsString((opcode shr 2) and $0003, param0);
        if args>1 then
          returnValue := returnValue + ', ' + getParameterAsString(opcode and $0003, param1);
      end;
    end;
    instructionToText := returnValue;
  end;

  { gets a source code file name and a binary file name }
  { returns true if build was successful, false if failed }
  function build(const sourceFilename, binaryFilename: string): boolean;
  var
    systemState: TSystemState; 
    symbolList: PSymbolNode;
    textFile: Text;
    line: string;
    lineNumber: word;
    flag: boolean;
    errorCode: EErrorCode;
  begin
    assign(textFile, sourceFilename);
    {$I-} reset(textFile); {$I+}
    if IOResult = 0 then
    begin
      fillchar(systemState, sizeof(TSystemState), 0);
      symbolList := nil; 
      lineNumber := 0;
      errorCode := readHeader(textFile, symbolList, systemState);
      if errorCode <> EErrorFatal then
      begin
        flag := true;
        while not seekeof(textFile) do
        begin
          readln(textFile, line);
          if line <> '' then
            flag := compileInstruction(line, systemState, symbolList, lineNumber) and flag;
        end;
        flag := listAndCleanSymbols(symbolList) and flag;
        saveState(systemState, binaryFilename);
      end else begin
        writeln('> ERROR: Code lacks the \\ASM signature');
        flag := false;
      end;
      close(textFile);
    end else begin
      flag := false;
      writeln('> ERROR: File "', sourceFilename, '" not found');
    end;
    build := flag;
  end;

end.