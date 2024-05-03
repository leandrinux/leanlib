uses
  lcparser;

var
  parser: PTextParser;

procedure testIsLiteral(str: string; value: ELiteralType);
const
  C_LITERAL_TYPES: array[ELiteralType] of string[10] = (
    'None', 'Char', 'Integer', 'Float'
  );
var
  result: ELiteralType;
begin
  write('testIsLiteral ', str:7, ' ');
  result := parser^.isLiteralType(str);
  write(C_LITERAL_TYPES[result], ' ');
  if result = value then 
    writeln('ok')
  else begin
    writeln('fail');
    writeln('TESTS FAILED');
    halt(1);
  end;
end;

begin
  parser := new(PTextParser, init);

  testIsLiteral('123', ELiteralInteger);
  testIsLiteral('a', ELiteralNone);
  testIsLiteral('344s3', ELiteralNone);
  testIsLiteral('abc', ELiteralNone);
  testIsLiteral('a234', ELiteralNone);
  testIsLiteral('+a', ELiteralNone);  
  testIsLiteral('''q''', ELiteralChar);
  testIsLiteral('', ELiteralNone);
  testIsLiteral('0', ELiteralInteger);
  testIsLiteral('+0', ELiteralInteger);
  testIsLiteral('-15', ELiteralInteger);
  testIsLiteral('.', ELiteralNone);
  testIsLiteral('.0', ELiteralNone);
  testIsLiteral('0.0', ELiteralFloat);
  testIsLiteral('123.123', ELiteralFloat);
  testIsLiteral('+13.1', ELiteralFloat);
  testIsLiteral('-13.', ELiteralNone);
  testIsLiteral('-62.7', ELiteralFloat);
  testIsLiteral('-982.76', ELiteralFloat);
  testIsLiteral('-15a', ELiteralNone);
  testIsLiteral('-15.6a', ELiteralNone);
  writeln('TESTS PASSED');
  parser^.release;
end.