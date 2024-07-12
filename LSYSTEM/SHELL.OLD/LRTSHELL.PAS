uses
  xcrt,
  utils, uobject, ulist, 
  lcommon, lbin;

type
  TToken = string[32];

  TShellCommandName = string[8];
  TShellCommandDetail = string[64];
  TShellCommandHandler = procedure (args: string);

  PShellCommand = ^TShellCommand;
  TShellCommand = packed record
    name: TShellCommandName;
    detail: TShellCommandDetail;
    handler: TShellCommandHandler;
  end;

  TSymbolName = TToken;
  PSymbol = ^TSymbol;
  TSymbol = object (TObject)
    name: TSymbolName;
    value: integer;
  end;

procedure doClear(args: string); far; forward;
procedure doDump(args: string); far; forward;
procedure doEdit(args: string); far; forward;
procedure doList(args: string); far; forward;
procedure doLoad(args: string); far; forward;
procedure doNew(args: string); far; forward;
procedure doHelp(args: string); far; forward;
procedure doRegs(args: string); far; forward;
procedure doSave(args: string); far; forward;
procedure doSymbols(args: string); far; forward;
procedure doSetSymbol(args: string); far; forward;
procedure doVerbose(args: string); far; forward;

const
  C_STR_UNRECOGNIZED_COMMAND = 'Unrecognized command';
  C_STR_NO_SYMBOLS = 'No symbols defined';
  C_STR_SYNTAX_ERROR = 'Syntax error';
  C_STR_SYMBOL_ADDED = 'Symbol added';
  C_STR_SYMBOL_REMOVED = 'Symbol removed';
  C_STR_SYMBOL_NOT_FOUND = 'Symbol not found';
  C_STR_INVALID_OPCODE = 'Invalid opcode';
  C_STR_INVALID_ARGUMENT = 'Invalid argument';
  C_STR_INVALID_ARGUMENT_COUNT = 'Wrong number of arguments';
  C_STR_IO_ERROR = 'I/O Error';

  C_SHELL_COMMAND_QUIT = 'exit';
  C_SHELL_COMMAND_COUNT = 13;
  C_SHELL_COMMANDS: array [0..C_SHELL_COMMAND_COUNT-1] of TShellCommand = (
    (name: 'clear'; detail: 'clears the screen'; handler:doClear),
    (name: 'dump'; detail: 'lists the memory state in the specified range A-B'; handler:doDump),
    (name: 'edit'; detail: 'enters code editing mode'; handler:doEdit),
    (name: 'help'; detail: 'displays this info'; handler:doHelp),
    (name: 'list'; detail: 'lists the code in memory'; handler:doList),
    (name: 'load'; detail: 'loads the system state from file'; handler:doLoad),
    (name: 'new'; detail: 'wipes the system state and starts from scratch'; handler:doNew),
    (name: 'regs'; detail: 'displays register values'; handler:doRegs),
    (name: 'save'; detail: 'saves the system state to file'; handler:doSave),
    (name: 'set'; detail: 'use to assign or delete a symbol. Use #, @ or $'; handler:doSetSymbol),
    (name: 'symbols'; detail: 'lists all symbols'; handler:doSymbols),
    (name: 'verbose'; detail: 'toggle verbosity'; handler:doVerbose),
    (name: C_SHELL_COMMAND_QUIT; detail: 'ends this shell session'; handler:nil)
  );

  C_IGNORE_CHARS = [#9, ' ', ','];

var
  systemState: TSystemState;
  symbolList: PList;
  verbose: boolean;

{ misc functions }

function assert(value: boolean; const msg: string): boolean;
begin
  if not value then writeln(msg);
  assert := value;
end;

{ system state }

procedure resetSystemState;
begin
  verbose := false;
  fillchar(systemState, sizeof(TSystemState), 0);
  if symbolList <> nil then symbolList^.release;
  symbolList := new(PList, init);
  systemState.registers[6] := C_DEFAULT_STACK_SIZE;
  systemState.ss := C_DEFAULT_MEMORY_SIZE - C_DEFAULT_STACK_SIZE;
end;

procedure initSystemState;
begin
  symbolList := nil;
  resetSystemState;
end;

procedure releaseSystemState;
begin
  symbolList^.release;
end;

{ symbol list management }

procedure deleteSymbol(const name: string);
var
  symbol: PSymbol;
begin
  with symbolList^ do begin
    moveToStart;
    symbol := PSymbol(getObjectAtCursor);
    while (symbol <> nil) and (symbol^.name <> name) do
    begin
      moveForward;
      symbol := PSymbol(getObjectAtCursor);
    end;
    if symbol <> nil then 
      symbolList^.removeObject(symbol);
  end;
end;

procedure addSymbol(const name: string; value: integer);
var
  symbol: PSymbol;
begin
  symbol := new(PSymbol, init);
  symbol^.name := name;
  symbol^.value := value;
  symbolList^.addObject(symbol);
  symbol^.release;
end;

function getSymbolValue(const name: TSymbolName; var symbolValue: integer): boolean;
var
  symbol: PSymbol;
begin
  getSymbolValue := true;
  with symbolList^ do begin
    moveToStart;
    symbol := PSymbol(getObjectAtCursor);
    while (symbol <> nil) and (symbol^.name <> name) do
    begin
      moveForward;
      symbol := PSymbol(getObjectAtCursor);
    end;
    if symbol <> nil then 
      symbolValue := symbol^.value
    else
      getSymbolValue := false;
  end;
end;

{ assembly processing }

procedure getToken(const line: string; var position:byte; var token: TToken);
begin
  token := '';
  while (position <= length(line)) and (line[position] in C_IGNORE_CHARS) do
    inc(position);
  while (position <= length(line)) and not (line[position] in C_IGNORE_CHARS) do 
  begin
    token := token + line[position]; 
    inc(position); 
  end;
end;

function getIndirectParameterValue(var registerValue: integer; const token: TToken): boolean;
var
  result: boolean;
  registerCode: byte;
  registerName: TRegisterName;
  constantStr: string[6];
  constantValue: shortint;
  code: integer;
begin
  getIndirectParameterValue := false;
  registerValue := 0;
  if length(token) < 4 then exit;
  registerName := token[2] + token[3];
  strUpper(registerName);
  if not getRegisterValue(registerName, registerCode) then exit;
  registerValue := registerCode;
  if length(token) > 4 then
  begin
    constantStr := copy(token, 5, length(token) - 4);
    val(constantStr, constantValue, code);
    if code <> 0 then exit;
    registerValue := (constantValue shl 8) or registerValue;
  end;
  getIndirectParameterValue := true;
end;

function getParameterValue(var paramValue: integer; paramType: EParameterType; const token: TToken): boolean;
var
  value: byte;
begin
  getParameterValue := true;
  case paramType of
    EParameterTypeInmediate:
      paramValue := strToInt(token);

    EParameterTypeSymbol:
      getParameterValue := getSymbolValue(token, paramValue);

    EParameterTypeAddress:
      paramValue := decToInt(token);

    EParameterTypeRegister:
    begin
      getParameterValue := getRegisterValue(token, value);
      paramValue := value;
    end;

    EParameterTypeIndirect:
      getParameterValue := getIndirectParameterValue(paramValue, token);
  
  else
    paramValue := 0;
  end;
end;

function parseAssemblyParameter(
  const assemblyLine: string; 
  var position: byte; 
  var paramType: EParameterType;
  var paramTypeCode: byte;
  var paramValue: integer): boolean;
var
  token: TToken;
begin
  parseAssemblyParameter := false;
  getToken(assemblyLine, position, token);
  strUpper(token);
  paramType := getParameterType(token);
  if not assert(paramType <> EParameterTypeInvalid, C_STR_INVALID_ARGUMENT) then exit;
  getParameterTypeCode(paramType, paramTypeCode);
  if not assert(getParameterValue(paramValue, paramType, token), C_STR_INVALID_ARGUMENT) then exit;
  parseAssemblyParameter := true;
end;

function parseAssembly(address: integer; const assemblyLine: string; var instruction: TInstruction): boolean;
var
  token: TToken;
  position: byte;
  paramType0, paramType1: EParameterType;
  paramTypeCode0, paramTypeCode1: byte;
  paramCount: byte;
  opcodeData: TOpcodeData;
begin
  parseAssembly := false;
  position := 1;
  getToken(assemblyLine, position, token);

  { get the label, if present }
  if (token[length(token)] = ':') then
  begin
    dec(token[0]);
    strUpper(token);
    deleteSymbol(token);
    addSymbol(token, address);
    getToken(assemblyLine, position, token);
  end;
  
  { get the opcode }
  if not assert(token <> '', C_STR_SYNTAX_ERROR) then exit;
  strUpper(token);
  with instruction do
  begin
    getOpcodeDataById(token, opcodeData);
    if not assert(opcodeData.code <> C_INVALID_OPCODE, C_STR_INVALID_OPCODE) then exit;
  end;

  if not assert(
    parseAssemblyParameter(assemblyLine, position, paramType0, paramTypeCode0, instruction.param0)
    , C_STR_INVALID_ARGUMENT) then exit;

  if not assert(
    parseAssemblyParameter(assemblyLine, position, paramType1, paramTypeCode1, instruction.param1)
    , C_STR_INVALID_ARGUMENT) then exit;

  paramCount := 0;
  if paramType0 <> EParameterTypeEmpty then inc(paramCount);
  if paramType1 <> EParameterTypeEmpty then inc(paramCount);
  if not assert(paramCount = opcodeData.args, C_STR_INVALID_ARGUMENT_COUNT) then exit;

  { set final opcode value including parameter types }
  with instruction do opcode := (opcodeData.code shl 8) or (paramTypeCode0 shl 2) or paramTypeCode1;

  if verbose then
  begin 
    writeln('  opcode: 0x', wordToHex(instruction.opcode));
    write('  param0: 0x', wordToHex(instruction.param0));
    writeln(', type:', paramTypeCode0, ' (', C_PARAMETER_TYPES[paramType0], ')');
    write('  param1: 0x', wordToHex(instruction.param1));
    writeln(', type:', paramTypeCode1, ' (', C_PARAMETER_TYPES[paramType1], ')');
    writeln;
  end;

  parseAssembly := true;
end;

{ command processing }  

procedure doClear(args: string);
begin
  clrscr;
end;

procedure doDump(args: string);
var
  position, fromAddress, toAddress, count: word;
begin
  position := pos('-', args);
  if position = 0 then
  begin
    writeln(' ', C_STR_SYNTAX_ERROR);
    exit;
  end;
  fromAddress := utils.strToInt(copy(args, 1, position-1));
  toAddress := utils.strToInt(copy(args, position+1, length(args)-position));
  count := 0;
  for position := fromAddress to toAddress do with systemState do
  begin
    if ((position - fromAddress) mod 16) = 0 then
    begin
      writeln;
      write('   $', wordToHex(position), ':  ');
    end;
    write(byteToHex(memory[position]), ' ');
    inc(count);
  end;
  writeln;
end;

procedure doEdit(args: string);
var 
  assemblyLine: string;
  address: integer;
  instruction: TInstruction;
  position: byte;
  token: TToken;
begin
  position := 1;
  getToken(args, position, token);
  if token = '' then
    address := systemState.ds
  else begin
    address := decToInt(token);
    if not assert((address mod 3) = 0, C_STR_INVALID_ARGUMENT) then exit;  
  end;
  repeat
    write(address:5, ': ');
    readln(assemblyLine);
    if (assemblyLine <> '') and parseAssembly(address, assemblyLine, instruction) then
    with systemState, instruction do begin
      memory[address] := opcode;
      memory[address+1] := param0;
      memory[address+2] := param1;
      inc(address, 3);
      with systemState do if ds < address then ds := address;
    end;
  until assemblyLine = '';
end;

procedure doList(args: string);
var
  address: word;
  instruction: PInstruction;
const
  C_SPACER = '     ';
begin
  address := 0;
  with systemState do while address < ds do
  begin
    instruction := @memory[address];
    with instruction^ do
    begin
      write('   $', wordToHex(address), C_SPACER, wordToHex(opcode));
      write(' ', wordToHex(param0));
      write(' ', wordToHex(param1));
    end;
    write(C_SPACER, instructionToText(instruction^));
    writeln;
    inc(address, 3);
  end;
end;

procedure doNew(args: string); 
begin
  resetSystemState;
end;

procedure doLoad(args: string); 
begin
  if not assert(args <> '', C_STR_SYNTAX_ERROR) then exit;
  if not assert(loadState(systemState, args), C_STR_IO_ERROR) then exit;
end;

procedure doSave(args: string); 
begin
  if not assert(args <> '', C_STR_SYNTAX_ERROR) then exit;
  if not assert(saveState(systemState, args), C_STR_IO_ERROR) then exit;
end;

procedure doSymbols(args: string); 
var
  symbol: PSymbol;
begin
  if symbolList^.getCount = 0 then
    writeln(' ', C_STR_NO_SYMBOLS)
  else with symbolList^ do begin
    moveToStart;
    symbol := PSymbol(getObjectAtCursor);
    while symbol <> nil do
    begin
      with symbol^ do writeln(' ', name, ' = #', value, ', 0x', wordToHex(value));
      moveForward;
      symbol := PSymbol(getObjectAtCursor);
    end;
  end;
end;

procedure doRegs(args: string);
var
  i: byte;
begin
  with systemState do
  begin
    write('   ');
    for i:=10 to 15 do
      write(chr(ord('A')+i-10),'X:', registers[i]:5, ' |' );
    writeln;
    write('   SS:', ss:5, ' |SP:', registers[6]:5, ' |BP:', registers[7]:5);
    writeln(' |DS:', ds:5, ' |CC:', registers[9]:5, ' |IP:', registers[8]:5, ' |');
  end;
end;

procedure doHelp(args: string);
var 
  i: byte;
begin
  i := 0;
  while (i<C_SHELL_COMMAND_COUNT) do
  begin
    with C_SHELL_COMMANDS[i] do writeln(' ', name:8, ': ', detail);
    inc(i);
  end; 
end;

procedure doSetSymbol(args: string);
var
  position: byte;
  name: TSymbolName;
  valueStr: string[7];
  value: integer;
begin
  position := pos('=', args);
  if position = 0 then
  begin
    writeln(' ', C_STR_SYNTAX_ERROR);
    exit;
  end;
  name := copy(args, 0, position-1);
  valueStr := copy(args, position+1, length(args) - position);
  if length(name) = 0 then
  begin
    writeln(' ', C_STR_SYNTAX_ERROR);
    exit;
  end;
  
  if (length(valueStr) > 0) and not (valueStr[1] in ['@', '$', '#']) then
  begin
    writeln(' ', C_STR_SYNTAX_ERROR);
    exit;
  end;

  strUpper(name);
  deleteSymbol(name);
  if length(valueStr) = 0 then exit;
  strUpper(valueStr);
  value := strToInt(valueStr);
  addSymbol(name, value);

  if verbose then
    writeln(' ', name, ' = #', value, ', 0x', wordToHex(value));
end;

procedure doVerbose(args: string);
begin
  verbose := not verbose;
  write('verbose is ');
  if verbose then writeln('on') else writeln('off');
end;

function findShellCommand(name: TShellCommandName): PShellCommand;
var 
  i: byte;
begin
  i := 0;
  while (i<C_SHELL_COMMAND_COUNT) and (C_SHELL_COMMANDS[i].name <> name) do inc(i);
  if i = C_SHELL_COMMAND_COUNT then
    findShellCommand := nil
  else
    findShellCommand := @C_SHELL_COMMANDS[i]; 
end;

procedure readCommands;
var
  commandLine: string;
  shellCommand: PShellCommand;
  shellArguments: string;
  position: byte;
begin
  write('> ');
  readln(commandLine);
  while commandLine <> C_SHELL_COMMAND_QUIT do
  begin
    position := pos(' ', commandLine);
    if position = 0 then
      shellArguments := ''
    else begin
      shellArguments := copy(commandLine, position + 1, length(commandLine) - position);
      delete(commandLine, position, length(commandLine) - position + 1);
    end;
    shellCommand := findShellCommand(commandLine);
    if shellCommand <> nil then
    begin
      if (@shellCommand^.handler <> nil) then
        shellCommand^.handler(shellArguments); 
    end else
      if length(commandLine) > 0 then writeln(' ', C_STR_UNRECOGNIZED_COMMAND);
    write('> ');
    readln(commandLine);
  end; 
end;

begin
  initSystemState;
  writeln('lrt interactive shell version ', C_SYSTEM_VERSION);
  readCommands;
  releaseSystemState;
end.