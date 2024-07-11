{
  LCParser test program
}

uses
  ustream, umstream, lcbase, lsrccode, lcparser;

const
  C_PARAMETER_TYPES: array [EParameterType] of string[15] = (
    'unknown', 'literal', 'register', 'address', 'pointer', 'symbol'
  );

procedure fail;
begin
  writeln('fail'); 
  halt(1);
end;

procedure writeArgument(const arg: TSentenceArgument);
begin
  with arg do
  begin
    write('type: ', C_PARAMETER_TYPES[argType]);
    write(', stringValue: ', stringValue);
    write(', intValue: ', intValue);
    write(', registerCode: ', registerCode);
    writeln(', offset: ', offset);
  end;
end;

function compareBuffers(a, b: PChar; size: word): boolean;
begin
  while (size>0) and (a^=b^) do
  begin
    inc(a);
    inc(b);
    dec(size);
  end;
  compareBuffers := size = 0;
end;

type
  TCompareError = string[30];

function compareSentences(const a, b: TSentence): TCompareError;
var 
  error: TCompareError;
begin
  error := '';
  if (a.labelName <> b.labelName) then error := 'labelName';
  if (a.opname <> b.opname) then error := 'opname';
  if (a.opcode <> b.opcode) then error := 'opcode';

  if (a.args[0].argType <> b.args[0].argType) then error := 'arg0 argType';
  if (a.args[0].stringValue <> b.args[0].stringValue) then error := 'arg0 stringValue';
  if (a.args[0].intValue <> b.args[0].intValue) then error := 'arg0 intValue';
  if (a.args[0].registerCode <> b.args[0].registerCode) then error := 'arg0 registerCode';
  if (a.args[0].offset <> b.args[0].offset) then error := 'arg0 offset';

  if (a.args[1].argType <> b.args[1].argType) then error := 'arg1 argType';
  if (a.args[1].stringValue <> b.args[1].stringValue) then error := 'arg1 stringValue';
  if (a.args[1].intValue <> b.args[1].intValue) then error := 'arg1 intValue';
  if (a.args[1].registerCode <> b.args[1].registerCode) then error := 'arg0 registerCode';
  if (a.args[1].offset <> b.args[1].offset) then error := 'arg1 offset';

  compareSentences := error;
end;

procedure writeSentence(const sentence: TSentence);
begin
  with sentence do
  begin
    write('label: ''', labelName, '''');
    write(', opname: ', opname);
    writeln(', opcode: ', opcode);
    writeArgument(args[0]);
    writeArgument(args[1]);
  end;
end;

procedure test(const data: string; const match: TSentence);
var
  stream: PMemoryStream;
  sourceCode: PSourceCode;
  parser: PCodeParser;
  sentence: TSentence;
  pdata: pchar;
  psize: word;
  compareError: TCompareError;
begin
  pdata := @data; 
  inc(pdata);
  psize := length(data);
  stream := new(PMemoryStream, initWithBuffer(pdata, psize));
  sourceCode := new(PSourceCode, initWithStream(stream));
  parser := new(PCodeParser, initWithSourceCode(sourceCode));
  { writeln('Given data:', data); } 
  { fillchar(sentence, sizeof(match), 0); }
  parser^.parseSentence(sentence);
  { writeSentence(sentence); }
  compareError := compareSentences(sentence, match);
  write('test "', data , '" ');
  if compareError='' then 
    writeln('passed')
  else begin
    writeln('comparison differs (', compareError, ') - failed');
    halt(1);
  end;
  stream^.release;
  parser^.release;
  sourceCode^.release;
end;

var
  match: TSentence;

begin

  with match do
  begin
    labelName := '';
    opname := 'mov';
    opcode := C_MOV;
    args[0].argType := EParameterTypeRegister;
    args[0].stringValue := 'ax';
    args[0].intValue := 0;
    args[0].registerCode := $51;
    args[0].offset := 0;
    args[1].argType := EParameterTypeLiteral;
    args[1].stringValue := '100';
    args[1].intValue := 100;
    args[1].registerCode := 0;
    args[1].offset := 0;
  end;
  test('mov ax, 100', match);


  with match do
  begin
    labelName := '';
    opname := 'cmp';
    opcode := C_CMP;
    args[0].argType := EParameterTypeRegister;
    args[0].stringValue := 'edx';
    args[0].intValue := 0;
    args[0].registerCode := $80;
    args[0].offset := 0;
    args[1].argType := EParameterTypeAddress;
    args[1].stringValue := '[0xBACAF0FA]';
    args[1].intValue := $BACAF0FA;
    args[1].registerCode := 0;
    args[1].offset := 0;
  end;
  test('cmp edx, [0xBACAF0FA]', match);


  with match do
  begin
    labelName := 'loop';
    opname := 'fdiv';
    opcode := C_FDIV;
    args[0].argType := EParameterTypePointer;
    args[0].stringValue := '[eax+0b_1111_0010]';
    args[0].intValue := 0;
    args[0].registerCode := $50;
    args[0].offset := $F2;
    args[1].argType := EParameterTypeSymbol;
    args[1].stringValue := 'cat';
    args[1].intValue := 0;
    args[1].registerCode := 0;
    args[1].offset := 0;
  end;
  test('loop: fdiv [eax+0b_1111_0010], cat', match);

  with match do
  begin
    labelName := '';
    opname := 'mov';
    opcode := C_MOV;
    args[0].argType := EParameterTypePointer;
    args[0].stringValue := '[ax]';
    args[0].intValue := 0;
    args[0].registerCode := $51;
    args[0].offset := 0;
    args[1].argType := EParameterTypeLiteral;
    args[1].stringValue := '200';
    args[1].intValue := 200;
    args[1].registerCode := 0;
    args[1].offset := 0;
  end;
  test('mov [ax], 200', match);

end.
