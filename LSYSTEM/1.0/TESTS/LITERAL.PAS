{$N+}

uses
  lcommon,
  lliteral;

type
  TFunction = function(const s: string; var value: TUInt32): boolean;

procedure testValue(func: TFunction; const s: string; expectedSuccess: boolean; expectedValue: TUInt32);
var
  value: TUInt32;
  result: boolean;
begin
  write('  ', s, ' - ');
  result := func(s, value);
  if expectedSuccess and result then
  begin
    if (value = expectedValue) then 
      writeln('passed')
    else begin
      writeln('fail. reported success but returned wrong value');
      halt(1);
    end;
  end else if expectedSuccess and (not result) then
  begin
    writeln('fail. expected success but returned false');
    halt(1);
  end else if (not expectedSuccess) and result then
  begin
    writeln('fail. expected to fail but returned success');
    halt(1);
  end else if (not expectedSuccess) and (not result) then
    writeln('failed successfully');
end;

procedure testFloat32(const s: string; expectedSuccess: boolean; expectedValue: TFloat32);
var
  value: TFloat32;
  result: boolean;
begin
  write('  ', s, ' - ');
  result := str2single(s, value);
  if (result <> expectedSuccess) and (value <> expectedValue) then 
  begin
    write('fail ');
    if expectedSuccess then 
      writeln('(expected ', expectedValue, ', got ', value, ')')
    else
      writeln('should return false');
    halt(1);
  end else
    writeln('pass');
end;

var 
  f: TFunction;

begin
  writeln('test for binary integers');
  f := bin2int;
  testValue(f, '0b0', true, 0);
  testValue(f, '0b1', true, 1);
  testValue(f, '0b10', true, 2);
  testValue(f, '0b1010', true, 10);
  testValue(f, '0b111010', true, 58);
  testValue(f, '0b10101100', true, 172);
  testValue(f, '0b__10__1_0__1100__', true, 172);
  testValue(f, '0b1010110010101100', true, 44204);
  testValue(f, '0b10101100101011001010110010101100', true, $ACACACAC);
  testValue(f, '0b1010_1100_1010_1100_1010_1100_1010_1100', true, $ACACACAC);
  testValue(f, '0b112010', false, 0);
  testValue(f, '0b_1_10101100_10101100_10101100_10101100', false, 0);
  testValue(f, '0b_0_10101100_10101100_10101100_10101100', false, 0);
  testValue(f, '0B10101100', false, 0);
  testValue(f, '0b', false, 0);
  testValue(f, '0', false, 0);
  testValue(f, '___', false, 0);
  testValue(f, '_', false, 0);
  testValue(f, '', false, 0);

  writeln('test for octal integers');
  f := oct2int;
  testValue(f, '0o0', true, 0);
  testValue(f, '0o1', true, 1);
  testValue(f, '0o10', true, 8);
  testValue(f, '0o123', true, 83);
  testValue(f, '0o1234', true, 668);
  testValue(f, '0o12345', true, 5349);
  testValue(f, '0o123456', true, 42798);
  testValue(f, '0o1234567', true, 342391);
  testValue(f, '0o123_454_321', true, 21911761);
  testValue(f, '#123_454_321', true, 21911761);
  testValue(f, '0o37777777777', true, $FFFFFFFF);
  testValue(f, '#37777777777', true, $FFFFFFFF);
  testValue(f, '0o_77777777', true, $FFFFFF);
  testValue(f, '0o0118010', false, 0);
  testValue(f, '0O0118010', false, 0);
  testValue(f, '0O', false, 0);
  testValue(f, '0', false, 0);
  testValue(f, '#', false, 0);
  testValue(f, '___', false, 0);
  testValue(f, '_', false, 0);
  testValue(f, '', false, 0);

  writeln('test for decimal integers');
  f := dec2int;
  testValue(f, '0', true, 0);
  testValue(f, '10', true, 10);
  testValue(f, '110', true, 110);
  testValue(f, '60000', true, 60000);
  testValue(f, '100000', true, 100000);
  testValue(f, '-110', true, -110);
  testValue(f, '-60000', true, -60000);
  testValue(f, '-100000', true, -100000);
  testValue(f, '1816_07_09', true, 18160709);
  testValue(f, '2_147_483_647', true, 2147483647);
  testValue(f, '-2_147_483_648', true, $80000000);
  testValue(f, 'A', false, 0);
  testValue(f, '_', false, 0);
  testValue(f, '1_A', false, 0);
  testValue(f, '', false, 0);

  writeln('test for hexadecimal integers');
  f := hex2int;
  testValue(f, '$0', true, 0);
  testValue(f, '0x0', true, 0);
  testValue(f, '0x1', true, 1);
  testValue(f, '0x10', true, $10);
  testValue(f, '0x123', true, $123);
  testValue(f, '0x1234', true, $1234);
  testValue(f, '0x12345', true, $12345);
  testValue(f, '0x123456', true, $123456);
  testValue(f, '0x1234567', true, $1234567);
  testValue(f, '0x1234_4321', true, $12344321);
  testValue(f, '0xABCDEF', true, $ABCDEF);
  testValue(f, '$ABCDEF', true, $ABCDEF);
  testValue(f, '0x_7777_7777', true, $77777777);
  testValue(f, '0xFFFFF', true, $FFFFF);
  testValue(f, '0x011G010', false, 0);
  testValue(f, '0X011G010', false, 0);
  testValue(f, '0X', false, 0);
  testValue(f, '0', false, 0);
  testValue(f, '$', false, 0);
  testValue(f, '_', false, 0);
  testValue(f, '___', false, 0);
  testValue(f, '', false, 0);
  testValue(f, '-0x10', false, 10);

  writeln('test for characters');
  f := chr2int;
  testValue(f, '''a''', true, ord('a'));
  testValue(f, '''$''', true, ord('$'));
  testValue(f, '''Q''', true, ord('Q'));
  testValue(f, '''', false, 0);
  testValue(f, 'a''', false, 0);
  testValue(f, '''ab''', false, 0);

  writeln('test for 32-bit floating point');
  testFloat32('0', true, 0);
  testFloat32('10', true, 10);
  testFloat32('1_0', true, 10);
  testFloat32('1.1', true, 1.1);
  testFloat32('-7.8', true, -7.8);
  testFloat32('123.345', true, 123.345);
  testFloat32('.5', true, 0.5);
  testFloat32('-.25', true, -0.25);

  writeln('test for any type');
  f := any2int;
  testValue(f, '''a''', true, ord('a'));
  testValue(f, '0x1234567', true, $1234567);
  testValue(f, '0xFFFFF', true, $FFFFF);

  writeln('test for any');
  f := any2int;
  testValue(f, '-0x10', false, 0);

  writeln('passed all tests!');
end.