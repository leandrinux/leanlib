unit 
  lbin;

interface

  uses
    lcommon;

  {$P+} { enables compatibility between strings of different type }

  const
    C_INVALID_OPCODE = $FF;    { invalid instruction code }
    C_INSTRUCTION_COUNT = 28;  { total number of supported instructions }

  function getOpcode(const instruction: TString7): byte;
  function build(const sourceFilename, binaryFilename: string): boolean;

implementation

  type
    EParameterType = (
      EParameterTypeInmediate,
      EParameterTypeSymbol,
      EParameterTypeAddress,
      EParameterTypeRegister,
      EParameterTypeIndirect,
      EParameterTypeEmpty
    );
   
    TTreeNode = record
      left, right: byte;
      id: TString7;
      code: byte;
    end;

    TTree = record
      root: byte;
      nodes: array[1 .. C_INSTRUCTION_COUNT] of TTreeNode;
    end;

    { Pending symbols list }
    PPendingSymbolNode = ^TPendingSymbolNode;
    TPendingSymbolNode = record
        position: TMemoryRange;
        next: PPendingSymbolNode;
    end;

    { Symbols list }
    PSymbolNode = ^TSymbolNode;
    TSymbolNode = record
        id: TString10;
        value: integer;
        pendingList: PPendingSymbolNode;
        next: PSymbolNode;
    end;

  const
    { search binary tree balanced by identifier }   
    C_INSTRUCTION_SET : TTree = (root:16; nodes:(
      (left:00;  right:00;  id:'JP';      code:$26),
      (left:27;  right:05;  id:'JE';      code:$22),
      (left:18;  right:26;  id:'OR';      code:$32),
      (left:00;  right:00;  id:'CMP';     code:$06),
      (left:10;  right:13;  id:'JMP';     code:$21),
      (left:08;  right:00;  id:'AND';     code:$31),
      (left:04;  right:09;  id:'DIV';     code:$05),
      (left:00;  right:00;  id:'ADD';     code:$02),
      (left:00;  right:00;  id:'DUMP';    code:$13),
      (left:12;  right:00;  id:'JL';      code:$24),
      (left:00;  right:00;  id:'JN';      code:$27),
      (left:00;  right:00;  id:'JG';      code:$23),
      (left:11;  right:01;  id:'JNZ';     code:$28),
      (left:15;  right:00;  id:'MOV';     code:$01),
      (left:00;  right:00;  id:'LSHIFT';  code:$07),
      (left:02;  right:25;  id:'JZ';      code:$25),
      (left:14;  right:03;  id:'MUL';     code:$04),
      (left:00;  right:00;  id:'NOT';     code:$33),
      (left:28;  right:22;  id:'STOP';    code:$77),
      (left:00;  right:00;  id:'RSHIFT';  code:$08),
      (left:00;  right:00;  id:'READ';    code:$11),
      (left:23;  right:24;  id:'WRITE';   code:$12),
      (left:00;  right:00;  id:'SUB';     code:$03),
      (left:00;  right:00;  id:'XOR';     code:$34),
      (left:17;  right:19;  id:'PUSH';    code:$41),
      (left:00;  right:00;  id:'POP';     code:$42),
      (left:06;  right:07;  id:'CALL';    code:$43),
      (left:21;  right:20;  id:'RET';     code:$44)
    ));

  {
    receives the list of symbols and a symbol identifier and returns pointer where a symbol is stored or nil if not found
  }
  function findSymbolNodeWithId(const list: PSymbolNode; const nid: TString10): PSymbolNode;
  var
    node: PSymbolNode;
  begin
    node := list;
    findSymbolNodeWithId := nil;
    if node <> nil then
    begin
      while (node<>nil) and (node^.id < nid) do node := node^.next;
      if (node<>nil) and (node^.id = nid) then findSymbolNodeWithId := node;
    end;
  end;

  { adds an element to the symbols list }
  function addToSymbolList(var list: PSymbolNode; const nid: TString10; value: integer): PSymbolNode;
  var 
    nnode, current, previous: PSymbolNode;
  begin
    new(nnode);
    nnode^.id := nid; 
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
  function getOpcode(const instruction: TString7): byte;
  var
    b: byte;
  begin
    with C_INSTRUCTION_SET do
    begin
      b := root;
      while (b<>0) and (nodes[b].id <> instruction) do
        if nodes[b].id < instruction then
          b := nodes[b].right
        else
          b := nodes[b].left;
      if b = 0 then
        getOpcode := C_INVALID_OPCODE
      else
        getOpcode := nodes[b].code;
    end;
  end;

  { extracts a token from the input string, removing it and returning it as output }
  procedure extractToken(var input:string; var token:string);
  const
    C_DELIMITERS: set of char = [' ', ',', ':', #9];
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
    types: array[1..2] of word;
    plus: integer;
    command: TString10; 
    lineCopy, aux, decstr: string;  
    opcode: byte;  
    parameterValue: ^integer;
    i, b: byte;
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
     opcode := getOpcode(command);
     if opcode = C_INVALID_OPCODE then
     begin
       instruction := C_NULL_INSTRUCTION;
       writeln('> ERROR: Invalid opcode ("', command, '")');
       compileInstruction := false;
     end else begin
       { fill up the instruction record }
       for i := 1 to 2 do
       begin

         if i = 1 then 
           parameterValue := @instruction.param1
         else
           parameterValue := @instruction.param2;

         extractToken(lineCopy, parameters[i]);
         if parameters[i] <> '' then
         begin
           aux := parameters[i];
           case getParameterType(aux) of

             EParameterTypeInmediate:
             begin
               types[i] := 0;
               parameterValue^ := strToInt(aux);
             end;
      
             EParameterTypeSymbol:
             begin
               types[i] := 0;
               node := findSymbolNodeWithId(symbolList, aux);
               if node = nil then
               begin
                 node := addToSymbolList(symbolList, aux, -1);
                 addPendingValue(node^.pendingList, systemState.ds + i);
                 parameterValue^ := -1;
               end else
                 { if there's no pending list, then the symbol value is already set }
                 if node^.pendingList = nil then
                   parameterValue^ := node^.value
                 else begin
                   addPendingValue(node^.pendingList, systemState.ds + i);
                   parameterValue^ := -1;
                 end;
             end;

             EParameterTypeAddress: 
             begin
               types[i] := 2;
               parameterValue^ := decToInt(aux);
             end;
             
             EParameterTypeRegister: 
             begin
               types[i] := 1;
               if aux[2] = 'X' then
                 parameterValue^ := hexToInt(aux[1])
               else
                 if aux[2] = 'P' then
                   case aux[1] of
                     'S': parameterValue^ := 6;
                     'I': parameterValue^ := 8;
                     'B': parameterValue^ := 7;
                   end
                 else
                   if aux[1] = 'CC' then
                     parameterValue^ := 9;
             end;
             
             EParameterTypeIndirect:
             begin
               types[i] := 3;
               { we get the code for the specified register }
               if aux[3] = 'X' then
                 parameterValue^ := hexToInt(aux[2])
               else
                 if aux[3] = 'P' then
                   case aux[2] of
                     'S': parameterValue^ := 6;
                     'I': parameterValue^ := 8;
                     'B': parameterValue^ := 7;
                   end
                 else
                   parameterValue^ := 9;
               { if there is a constant present then we get its value }
               aux := aux + lineCopy;
               b := pos(',', aux);
               if b<>0 then delete(aux, b, ord(aux[0])-b+1);
               delete(aux, 1, 4);
               extractToken(aux, decstr);
               if decstr = '' then
                 plus := 0
               else begin
                 plus := 1;
                 if decstr[1] in ['+', '-'] then
                 begin
                   if decstr[1] = '-' then plus := -1;
                   delete(decstr, 1, 1);
                 end;
                 plus := (plus * decToInt(decstr)) shl 4;
               end;
               { we form the value for this parameter and assign it }
               parameterValue^ := parameterValue^ or plus;
             end;
           end; { case end}
         end else begin 
           { if parameter doesn't exist then assign default values }
           parameterValue^ := 0;
           types[i] := 0;
         end
       end; { end of parameter for cycle }
       instruction.opcode := (opcode shl 8) or (types[1] shl 2) or types[2];
     end;
     lineNumber := lineNumber + 1;
     with systemState, instruction do
     begin
       writeln('[', wordToHex(DS), ']  ', wordToHex(opcode), ' ',
         wordToHex(param1),' ', wordToHex(param2), lineNumber:5, ':', line
       );
       memory[ds] := opcode;
       memory[ds+1] := param1;
       memory[ds+2] := param2;
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
          registers[6] := 200;
          ss := 1800;
        end else begin
          registers[6] := decToInt(line);
          ss := 2000 - registers[6];
        end;
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