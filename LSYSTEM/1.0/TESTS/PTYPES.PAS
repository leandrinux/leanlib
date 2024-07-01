uses
  lcbase;

procedure testParamType(const literal: string; expected:EParameterType);
var
  ptype: EParameterType;
begin
  write(literal,' ...');
  ptype := getParameterType(literal);
  if ptype = expected then 
    writeln('ok')
  else begin
    writeln('failed! expected ', ord(expected), ', got ', ord(ptype));
    halt(1);
  end;
end;

begin
  testParamType('0', EParameterTypeLiteral);
  testParamType('123232', EParameterTypeLiteral);
  testParamType('+123232', EParameterTypeLiteral);
  testParamType('-123232', EParameterTypeLiteral);
  testParamType('$A', EParameterTypeLiteral);
  testParamType('$AAA', EParameterTypeLiteral);
  testParamType('$AAAA', EParameterTypeLiteral);
  testParamType('$FAFAFAFA', EParameterTypeLiteral);

  testParamType('sp', EParameterTypeRegister);
  testParamType('bp', EParameterTypeRegister);
  testParamType('ip', EParameterTypeRegister);
  testParamType('cc', EParameterTypeRegister);
  testParamType('eax', EParameterTypeRegister);
  testParamType('ax', EParameterTypeRegister);
  testParamType('ah', EParameterTypeRegister);
  testParamType('al', EParameterTypeRegister);
  testParamType('ebx', EParameterTypeRegister);
  testParamType('bx', EParameterTypeRegister);
  testParamType('bh', EParameterTypeRegister);
  testParamType('bl', EParameterTypeRegister);
  testParamType('ecx', EParameterTypeRegister);
  testParamType('cx', EParameterTypeRegister);
  testParamType('ch', EParameterTypeRegister);
  testParamType('cl', EParameterTypeRegister);
  testParamType('edx', EParameterTypeRegister);
  testParamType('dx', EParameterTypeRegister);
  testParamType('dh', EParameterTypeRegister);
  testParamType('dl', EParameterTypeRegister);
  testParamType('cs', EParameterTypeRegister);
  testParamType('ds', EParameterTypeRegister);
  testParamType('ss', EParameterTypeRegister);

  testParamType('[10]', EParameterTypeAddress);
  testParamType('[0]', EParameterTypeAddress);
  testParamType('[-10]', EParameterTypeAddress);
  testParamType('[$A000]', EParameterTypeAddress);
  testParamType('[#60]', EParameterTypeAddress);
  testParamType('[0xFAFA]', EParameterTypeAddress);
  testParamType('[0b0010101]', EParameterTypeAddress);
  {testParamType('[video]', EParameterTypeAddress);}

  testParamType('[ax]', EParameterTypePointer);
  testParamType('[edx]', EParameterTypePointer);
  testParamType('[dl]', EParameterTypePointer);
  testParamType('[ds+1]', EParameterTypePointer);
  testParamType('[ds+0xFA]', EParameterTypePointer);
  testParamType('[ds-10]', EParameterTypePointer);
 
  testParamType('lalala', EParameterTypeSymbol);
  testParamType('axa', EParameterTypeSymbol);
  testParamType('eaxsd', EParameterTypeSymbol);

  testParamType('[ds]+1', EParameterTypeUnknown);
end.