uses
  lcbase;

  procedure testGetOpcodeInfoByName;
    procedure test(name: TInstructionName; expectedCode, expectedCount: byte);
    var
      code, count: byte;
    begin
      write('> ', name, ', code:', expectedCode, ', count:', expectedCount, ' ...');
      getOpcodeInfoByName(name, code, count);
      if (code <> expectedCode) or (count <> expectedCount) then
      begin
        writeln('fail'); 
        halt(1);
      end;
      writeln('pass');
    end;
  begin
    writeln('test getOpcodeInfoByName');
    test('mov', $1, 2);
    test('shl', $7, 2);
    test('fdiv', $C, 2);
    test('jmp', $21, 1);
    test('and', $31, 2);
    test('pusha', $43, 0);
    test('out', $51, 2);
    test('xor', $34, 2);
  end;

  procedure testGetRegisterInfoByName;
    procedure test(name: TRegisterName; expectedCode, expectedBitSize: byte);
    var
      code, bitSize: byte;
    begin
      write('> ', name, ', code:', expectedCode, ', bitSize:', expectedBitSize, ' ...');
      GetRegisterInfoByName(name, code, bitSize);
      if (code <> expectedCode) or (bitSize <> expectedBitSize) then
      begin
        writeln('fail'); 
        halt(1);
      end;
      writeln('pass');
    end;
  begin
    writeln('test getRegisterInfoByName');
    test('eax', $50, 32);
    test('ds', $A1, 32);
    test('dh', $82, 8);
  end;

  procedure testGuessParameterType;
    procedure test(token: string; expectedType:EParameterType);
    begin
      write('> ', token, ' ...');
      if getParameterType(token) <> expectedType then 
      begin
        writeln('fail'); 
        halt(1);
      end;
      writeln('pass');
    end;
  begin
    writeln('test getParameterType');
    test('0', EParameterTypeLiteral);
    test('1', EParameterTypeLiteral);
    test('-23', EParameterTypeLiteral);
    test('+5', EParameterTypeLiteral);
    test('$AA', EParameterTypeLiteral);
    test('#AA', EParameterTypeLiteral);
    test('0xCAFE', EParameterTypeLiteral);
    test('0b110101', EParameterTypeLiteral);
    test('''a''', EParameterTypeLiteral);

    test('eax', EParameterTypeRegister);
    test('ds', EParameterTypeRegister);
    test('cc', EParameterTypeRegister);
    test('bh', EParameterTypeRegister);

    test('[1000]', EParameterTypeAddress);
    test('[0xA000]', EParameterTypeAddress);
    test('[$FFFF]', EParameterTypeAddress);

    test('[eax]', EParameterTypePointer);
    test('[al]', EParameterTypePointer);
    test('[ds]', EParameterTypePointer);
    test('[cc]', EParameterTypePointer);
    test('[eax+10]', EParameterTypePointer);
    test('[ds+0x0A]', EParameterTypePointer);
    test('[cx+$10]', EParameterTypePointer);
    test('[cl-0b10101010]', EParameterTypePointer);

    test('[eqx+10]', EParameterTypeUnknown);
    test('[edx]+10', EParameterTypeUnknown);
  end;

begin
  testGetOpcodeInfoByName;
  testGetRegisterInfoByName;
  testGuessParameterType;
end.