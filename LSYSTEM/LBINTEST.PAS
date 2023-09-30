uses
  lcommon, lbin;

procedure test(pass: boolean; title: string);
begin
  if pass then
    writeln('[PASS] ', title)
  else begin
    writeln('[FAIL] ', title);
    writeln;
    writeln('TESTS FAILED');
    halt(1);
  end;
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
  addToSymbolList(symbolList, 'fourth', 40);

  test(findSymbolNodeWithId(symbolList, 'first') <> nil, 'findSymbolNodeWithId should find "first" ');
  test(findSymbolNodeWithId(symbolList, 'second') <> nil, 'findSymbolNodeWithId should find "second" ');
  test(findSymbolNodeWithId(symbolList, 'fourth') <> nil, 'findSymbolNodeWithId should find "fourth" ');
  test(findSymbolNodeWithId(symbolList, 'duck') = nil, 'findSymbolNodeWithId should not find "duck" ');

  { clean up }
  while (symbolList <> nil) do 
  begin
    node := symbolList^.next;
    dispose(symbolList);
    symbolList := node;
  end;
end; 

begin
  testOpcodes;
  testSymbolNodeList;
  writeln;
  writeln('TESTS SUCCEEDED');
end.