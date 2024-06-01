uses
  lcommon,
  literals;

procedure testBinaryValue(const s: string; expectedSuccess: boolean; expectedValue: TUInt32);
var
  value: TUInt32;
  result: boolean;
begin
  write('  ', s, ' - ');
  result := getBinaryValue(s, value);
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
  testBinaryValue('0b0', true, 0);
  testBinaryValue('0b1', true, 1);
  testBinaryValue('0b10', true, 2);
  testBinaryValue('0b1010', true, 10);
  testBinaryValue('0b111010', true, 58);
  testBinaryValue('0b10101100', true, 172);
  testBinaryValue('0b__10__1_0__1100__', true, 172);
  testBinaryValue('0b1010110010101100', true, 44204);
  testBinaryValue('0b10101100101011001010110010101100', true, $ACACACAC);
  testBinaryValue('0b1010_1100_1010_1100_1010_1100_1010_1100', true, $ACACACAC);
  testBinaryValue('0b112010', false, 0);
  testBinaryValue('0b_1_10101100_10101100_10101100_10101100', false, 0);
  testBinaryValue('0b_0_10101100_10101100_10101100_10101100', false, 0);
  testBinaryValue('0B10101100', false, 0);
  testBinaryValue('0b', false, 0);
  testBinaryValue('0', false, 0);
  testBinaryValue('', false, 0);
end.