uses
  lcommon,
  literals;

type
  TConversionFunc = function(const s: string; var value: TUInt32): boolean;

procedure testValue(func: TConversionFunc; const s: string; expectedSuccess: boolean; expectedValue: TUInt32);
var
  value: TUInt32;
  result: boolean;
begin
  write('  ', s, ' - ');
  result := func(s, value);
  if (result <> expectedSuccess) and (value <> expectedValue) then 
  begin
    write('fail! ');
    if expectedSuccess then 
      writeln('expected ', expectedValue, ', got ', value)
    else
      writeln('should return false');
    halt(1);
  end else
    writeln('ok');
end;

begin
  writeln('test for binary integers');
  testValue(getBinaryValue, '0b0', true, 0);
  testValue(getBinaryValue, '0b1', true, 1);
  testValue(getBinaryValue, '0b10', true, 2);
  testValue(getBinaryValue, '0b1010', true, 10);
  testValue(getBinaryValue, '0b111010', true, 58);
  testValue(getBinaryValue, '0b10101100', true, 172);
  testValue(getBinaryValue, '0b__10__1_0__1100__', true, 172);
  testValue(getBinaryValue, '0b1010110010101100', true, 44204);
  testValue(getBinaryValue, '0b10101100101011001010110010101100', true, $ACACACAC);
  testValue(getBinaryValue, '0b1010_1100_1010_1100_1010_1100_1010_1100', true, $ACACACAC);
  testValue(getBinaryValue, '0b112010', false, 0);
  testValue(getBinaryValue, '0b_1_10101100_10101100_10101100_10101100', false, 0);
  testValue(getBinaryValue, '0b_0_10101100_10101100_10101100_10101100', false, 0);
  testValue(getBinaryValue, '0B10101100', false, 0);
  testValue(getBinaryValue, '0b', false, 0);
  testValue(getBinaryValue, '0', false, 0);
  testValue(getBinaryValue, '', false, 0);

  writeln('test for octal integers');
  testValue(getOctalValue, '0o0', true, 0);
  testValue(getOctalValue, '0o1', true, 1);
  testValue(getOctalValue, '0o10', true, 8);
  testValue(getOctalValue, '0o123', true, 83);
  testValue(getOctalValue, '0o1234', true, 668);
  testValue(getOctalValue, '0o12345', true, 5349);
  testValue(getOctalValue, '0o123456', true, 42798);
  testValue(getOctalValue, '0o1234567', true, 342391);
  testValue(getOctalValue, '0o123_454_321', true, 21911761);
  testValue(getOctalValue, '0o37777777777', true, $FFFFFFFF);
  testValue(getOctalValue, '0o_77777777', true, $FFFFFF);
  testValue(getOctalValue, '0o0118010', false, 0);
  testValue(getOctalValue, '0O0118010', false, 0);
  testValue(getOctalValue, '0O', false, 0);
  testValue(getOctalValue, '0', false, 0);
  testValue(getOctalValue, '', false, 0);

  writeln('test for hexadecimal integers');
  testValue(getHexadecimalValue, '0x0', true, 0);
  testValue(getHexadecimalValue, '0x1', true, 1);
  testValue(getHexadecimalValue, '0x10', true, $10);
  testValue(getHexadecimalValue, '0x123', true, $123);
  testValue(getHexadecimalValue, '0x1234', true, $1234);
  testValue(getHexadecimalValue, '0x12345', true, $12345);
  testValue(getHexadecimalValue, '0x123456', true, $123456);
  testValue(getHexadecimalValue, '0x1234567', true, $1234567);
  testValue(getHexadecimalValue, '0x1234_4321', true, $12344321);
  testValue(getHexadecimalValue, '0xABCDEF', true, $ABCDEF);
  testValue(getHexadecimalValue, '0x_77777777', false, $77777777);
  testValue(getHexadecimalValue, '0x011G010', false, 0);
  testValue(getHexadecimalValue, '0X011G010', false, 0);
  testValue(getHexadecimalValue, '0X', false, 0);
  testValue(getHexadecimalValue, '0', false, 0);
  testValue(getHexadecimalValue, '', false, 0);

end.