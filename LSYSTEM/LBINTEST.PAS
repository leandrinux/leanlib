uses
  lcommon, lbin;

procedure test(pass: boolean; title: string);
begin
  if pass then
  begin
    writeln('[PASS] ', title);
  end else begin
    writeln('[FAIL] ', title);
    writeln;
    writeln('TESTS FAILED');
    halt(1);
  end;
end;

function getOpcode(id: TOpcodeId): byte;
var
  opcodeData: TOpcodeData;
begin
  getOpcodeDataById(id, opcodeData);
  getOpcode := opcodeData.code;
end;

procedure testOpcodes;
type
  TOpcodePair = packed record
    opcode: string[6];
    value: byte;
  end;
const
  C_OPCODE_COUNT = 27;
  C_OPCODE_PAIRS: array [0 .. C_OPCODE_COUNT-1] of TOpcodePair = (
    (opcode: 'JMP'; value: $21),
    (opcode: 'JP'; value: $26),
    (opcode: 'JN'; value: $27),
    (opcode: 'JNZ'; value: $28),
    (opcode: 'JZ'; value: $25),
    (opcode: 'JL'; value: $24),
    (opcode: 'JE'; value: $22),
    (opcode: 'JG'; value: $23),
    (opcode: 'MOV'; value: $01),
    (opcode: 'ADD'; value: $02),
    (opcode: 'SUB'; value: $03),
    (opcode: 'MUL'; value: $04),
    (opcode: 'DIV'; value: $05),
    (opcode: 'LSHIFT'; value: $07),
    (opcode: 'RSHIFT'; value: $08),
    (opcode: 'AND'; value: $31),
    (opcode: 'OR'; value: $32),
    (opcode: 'NOT'; value: $33),
    (opcode: 'XOR'; value: $34),
    (opcode: 'PUSH'; value: $41),
    (opcode: 'POP'; value: $42),
    (opcode: 'CALL'; value: $43),
    (opcode: 'RET'; value: $44),
    (opcode: 'READ'; value: $11),
    (opcode: 'WRITE'; value: $12),
    (opcode: 'DUMP'; value: $13),
    (opcode: 'STOP'; value: $77)
  );
var
  i: byte;
begin
  i := 0;
  while i < C_OPCODE_COUNT do
  begin
    with C_OPCODE_PAIRS[i] do
      test(getOpcode(opcode) = value, 'getOpcode(' + opcode + ')');
    inc(i);
  end;
  test(getOpcode('AAA') = C_INVALID_OPCODE, 'getOpcode(AAA) must be invalid');
  test(getOpcode('ZZZ') = C_INVALID_OPCODE, 'getOpcode(ZZZ) must be invalid');
end;

procedure testSymbolNodeList;
var
  symbolList, node: PSymbolNode;
begin
  symbolList := nil;
  addToSymbolList(symbolList, 'first', 20);
  addToSymbolList(symbolList, 'second', 30);
  addToSymbolList(symbolList, 'third', 40);
  addToSymbolList(symbolList, 'fourth', 50);

  test(findSymbolNodeWithId(symbolList, 'first')^.id = 'first', 'findSymbolNodeWithId must find "first" ');
  test(findSymbolNodeWithId(symbolList, 'second')^.id = 'second', 'findSymbolNodeWithId must find "second" ');
  test(findSymbolNodeWithId(symbolList, 'fourth')^.id = 'fourth', 'findSymbolNodeWithId must find "fourth" ');
  test(findSymbolNodeWithId(symbolList, 'duck') = nil, 'findSymbolNodeWithId must not find "duck" ');

  { clean up }
  while (symbolList <> nil) do 
  begin
    node := symbolList^.next;
    dispose(symbolList);
    symbolList := node;
  end;
end; 

procedure testExtractToken;
var
  testString, token: string;  
begin
  testString := 'LABEL: ' + #9 + ' MOV     AX  , $1';
  extractToken(testString, token);
  test(token = 'LABEL', 'extractToken must return "LABEL"');
  extractToken(testString, token);
  test(token = 'MOV', 'extractToken must return "MOV"');
  extractToken(testString, token);
  test(token = 'AX', 'extractToken must return "AX"');
  extractToken(testString, token);
  test(token = '$1', 'extractToken must return "$1"');
end;

procedure testGetParameterType;
const
  C_REGISTERS: array [0..9] of string[2] = 
    ( 'AX', 'BX', 'CX', 'DX', 'EX', 'FX', 'SP', 'BP', 'IP', 'CC');
var
  i: byte;
begin
  test(getParameterType('') = EParameterTypeEmpty, 'getParameterType "" must return empty');

  test(getParameterType('#25') = EParameterTypeInmediate, 'getParameterType #25 must return literal');
  test(getParameterType('@25') = EParameterTypeInmediate, 'getParameterType @25 must return literal');
  test(getParameterType('$25') = EParameterTypeInmediate, 'getParameterType $25 must return literal');

  test(getParameterType('0') = EParameterTypeAddress, 'getParameterType 0 must return address');
  test(getParameterType('1233') = EParameterTypeAddress, 'getParameterType 1233 must return address');

  for i := 0 to 9 do
    test(getParameterType(C_REGISTERS[i]) = EParameterTypeRegister, 
      'getParameterType ' + C_REGISTERS[i] + ' must return register'
    );
  test(getParameterType('AXA') = EParameterTypeSymbol, 'getParameterType AXA must return symbol');
  test(getParameterType('SPX') = EParameterTypeSymbol, 'getParameterType SPX must return symbol');
  test(getParameterType('IPT') = EParameterTypeSymbol, 'getParameterType IPT must return symbol');
  test(getParameterType('DUCK') = EParameterTypeSymbol, 'getParameterType DUCK must return symbol');

  test(getParameterType('[AX]') = EParameterTypeIndirect, 'getParameterType [AX] must return indirect');
  test(getParameterType('[BP]+1') = EParameterTypeIndirect, 'getParameterType [BP]+1 must return indirect');
  test(getParameterType('[BP]-3') = EParameterTypeIndirect, 'getParameterType [BP]-3 must return indirect');
end;

procedure testAddPendingValue;
var
  list, node: PPendingSymbolNode;
  memBefore: longint;
begin
  memBefore := memAvail;
  list := nil;
  addPendingValue(list, 32767);
  test(list^.position = 32767, 'addPendingValue must add 32767 to the list');
  addPendingValue(list, -32768);
  test(list^.position = -32768, 'addPendingValue must add -32768 to the list');
  { clean up list }
  while list <> nil do
  begin
    node := list^.next;
    dispose(list);
    list := node;
  end;  
  test((memAvail - memBefore) = 0, 'addPendingValue tests must not lose memory');
end;

procedure testClearPendingList;
var
  symbolList: PSymbolNode;
  systemState: TSystemState;
  memBefore: longint;
begin
  memBefore := memAvail;
  symbolList := nil;
  addToSymbolList(symbolList, 'symbol', 12345);
  addPendingValue(symbolList^.pendingList, 10);
  addPendingValue(symbolList^.pendingList, 15);
  fillChar(systemState, sizeOf(TSystemState), 0);
  clearPendingList(symbolList, systemState);
  test(symbolList^.pendingList = nil, 'clearPendingList must leave an empty pending list');
  test(systemState.memory[10] = 12345, 'clearPendingList must write 12345 to address 10');
  test(systemState.memory[15] = 12345, 'clearPendingList must write 12345 to address 15');
  dispose(symbolList);
  test((memAvail - memBefore) = 0, 'clearPendingList tests must not lose memory');
end;

procedure testCompileInstruction(
  line: string;
  opcode: byte;
  paramType0: byte;
  paramType1: byte;
  param0: word;
  param1: word
);
var
  systemState: TSystemState;
  symbolList: PSymbolNode;
  lineNumber: word;
begin
  fillChar(systemState, sizeOf(TSystemState), 0);
  symbolList := nil;
  lineNumber := 0;
  test(compileInstruction(line, systemState, symbolList, lineNumber), 'compileInstruction must return true');
  test((systemState.memory[0] shr 8) = opcode, 'compileInstruction opcode must be correct');
  test(((systemState.memory[0] and $000C) shr 2) = paramType0, 'compileInstruction opcode first param type must be correct');
  test((systemState.memory[0] and $0003) = paramType1, 'compileInstruction opcode second param type must be correct');
  test(systemState.memory[1] = param0, 'compileInstruction opcode first param must be correct');
  test(systemState.memory[2] = param1, 'compileInstruction opcode second param must be correct');
end;

procedure testInstructions;
var
  memBefore: longint;
begin
  memBefore := memAvail;
  testCompileInstruction('mov ax, 128', $01, 1, 2, 10, 128);
  testCompileInstruction('and fx, $FA', $31, 1, 0, 15, $FA);
  testCompileInstruction('cmp 120, [bp]+3', $06, 2, 3, 120, $37);
  testCompileInstruction('stop', $77, 0, 0, 0, 0);
  test((memAvail - memBefore) = 0, 'compileInstruction tests must not lose memory'); 
end;

begin
  testOpcodes;
  testSymbolNodeList;
  testExtractToken;
  testGetParameterType;
  testAddPendingValue;
  testClearPendingList;
  testInstructions;
  writeln;
  writeln('TESTS SUCCEEDED');
end.