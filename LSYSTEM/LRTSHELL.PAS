uses
  uobject, ulist, 
  lcommon, lbin;

type
  TShellCommandName = string[8];
  TShellCommandDetail = string[64];
  TShellCommandHandler = procedure (args: string);

  PShellCommand = ^TShellCommand;
  TShellCommand = packed record
    name: TShellCommandName;
    detail: TShellCommandDetail;
    handler: TShellCommandHandler;
  end;

  TSymbolName = string[10];
  PSymbol = ^TSymbol;
  TSymbol = object (TObject)
    name: TSymbolName;
    value: integer;
  end;

procedure doEdit(args: string); far; forward;
procedure doHelp(args: string); far; forward;
procedure doRegs(args: string); far; forward;
procedure doSymbols(args: string); far; forward;
procedure doSetSymbol(args: string); far; forward;

const
  C_STR_UNRECOGNIZED_COMMAND = 'Unrecognized command';
  C_STR_NO_SYMBOLS = 'No symbols defined';
  C_STR_SYNTAX_ERROR = 'Syntax error';
  C_STR_SYMBOL_ADDED = 'Symbol added';
  C_STR_SYMBOL_REMOVED = 'Symbol removed';
  C_STR_SYMBOL_NOT_FOUND = 'Symbol not found';

  C_SHELL_COMMAND_QUIT = 'exit';
  C_SHELL_COMMAND_COUNT = 6;
  C_SHELL_COMMANDS: array [0..C_SHELL_COMMAND_COUNT-1] of TShellCommand = (
    (name: 'edit'; detail: 'starts code editing mode'; handler:doEdit),
    (name: 'help'; detail: 'displays this info'; handler:doHelp),
    (name: 'regs'; detail: 'displays register values'; handler:doRegs),
    (name: 'set'; detail: 'sets a symbol value'; handler:doSetSymbol),
    (name: 'symbols'; detail: 'lists all symbols'; handler:doSymbols),
    (name: C_SHELL_COMMAND_QUIT; detail: 'ends this shell session'; handler:nil)
  );

var
  systemState: TSystemState;
  symbolList: PList;

procedure doEdit(args: string);
var 
  line: string;
  position: integer;
begin
  position := systemState.ds;
  repeat
    write(' 0000 ');
    readln(line);
  until line = '';
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
      with symbol^ do writeln(' ', name, ': ', value);
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
  valueStr: string[6];
  symbol: PSymbol;
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
  
  if length(valueStr) > 0 then
  begin
    if not (valueStr[1] in ['@', '$', '#']) then
    begin
      writeln(' ', C_STR_SYNTAX_ERROR);
      exit;
    end;
    { adds the symbol to the list }
    symbol := new(PSymbol, init);
    symbol^.name := name;
    symbol^.value := strToInt(valueStr);
    symbolList^.addObject(symbol);
    symbol^.release;
    writeln(' ', C_STR_SYMBOL_ADDED);
  end else with symbolList^ do begin
    { deletes the symbol from the list }
    moveToStart;
    symbol := PSymbol(getObjectAtCursor);
    while (symbol <> nil) and (symbol^.name = name) do
    begin
      moveForward;
      symbol := PSymbol(getObjectAtCursor);
    end;
    if symbol <> nil then 
    begin 
      symbolList^.removeObject(symbol);
      writeln(' ', C_STR_SYMBOL_REMOVED);
    end else
      writeln(' ', C_STR_SYMBOL_NOT_FOUND);
  end; 
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

procedure initSystemState;
begin
  fillchar(systemState, sizeof(TSystemState), 0);
  symbolList := new(PList, init);
  systemState.registers[6] := C_DEFAULT_STACK_SIZE;
  systemState.ss := C_DEFAULT_MEMORY_SIZE - C_DEFAULT_STACK_SIZE;
end;

procedure releaseSystemState;
begin
  symbolList^.release;
end;

begin
  initSystemState;
  writeln('lrt interactive shell version ', C_SYSTEM_VERSION);
  readCommands;
  releaseSystemState;
end.