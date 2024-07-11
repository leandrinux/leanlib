{
  LBinary test program
}
uses
  ustream, umstream, lcbase, lcommon, lbinary, utils;

const
  C_SYMBOL_CAT = $0C47;

procedure make(const sentence: TSentence; var instruction: TInstruction);
var 
  stream: PMemoryStream;
  binary: PBinary;
begin
  binary := new(PBinary, init);
  stream := new(PMemoryStream, initWithSize(128));
  binary^.addSentence(sentence);
  binary^.addDefinition('cat', C_SYMBOL_CAT);
  binary^.make;
  binary^.save(stream);
  stream^.seek(sizeof(C_BINARY_SIGNATURE));
  stream^.read(@instruction, sizeof(TInstruction));
  stream^.release;
  binary^.release;
end;

procedure writeInstruction(const instruction: TInstruction);
begin
  with instruction.header do writeln('opcode: $', byteToHex(opcode), ', params: $', byteToHex(params));
  with instruction do write('param0: $', longToHex(param0), ' (', param0,'), ');
  with instruction do writeln('param1: $', longToHex(param1), ' (', param1,')');
end;

procedure fail(const msg: string);
begin
  write(msg);
  writeln(' mismatch!');
  halt(1);
end;

procedure compare(const instruction, match: TInstruction);
begin
  if instruction.header.opcode <> match.header.opcode then fail('opcode');
  if instruction.header.params <> match.header.params then fail('params');
  if instruction.param0 <> match.param0 then fail('param0');
  if instruction.param1 <> match.param1 then fail('param1');
  writeln('passed');
end;

procedure test(const sentence: TSentence; const match: TInstruction);
var
  instruction: TInstruction;
begin
  make(sentence, instruction);
  writeInstruction(instruction);
  compare(instruction, match);
end;

var
  sentence: TSentence;
  match: TInstruction;

begin

  with sentence do
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
  with match do
  begin
    header.opcode := $01;
    header.params := $10;
    param0 := $51;
    param1 := 100;
  end;
  test(sentence, match);


  with sentence do
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
  with match do
  begin
    header.opcode := $06;
    header.params := $12;
    param0 := $80;
    param1 := $BACAF0FA;
  end;
  test(sentence, match);


  with sentence do
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
  with match do
  begin
    header.opcode := $0C;
    header.params := $30;
    param0 := $00F20050; { EAX = $50, OFFSET=$F2 }
    param1 := C_SYMBOL_CAT;
  end;
  test(sentence, match);


  with sentence do
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
  with match do
  begin
    header.opcode := $01;
    header.params := $30;
    param0 := $00000051; { AX = $51, OFFSET=0 }
    param1 := 200;
  end;
  test(sentence, match);

end.