unit 
  literals;

interface

  uses
    lcommon;

  function getBinaryValue(const s: string; var value: TUInt32): boolean;
  function getOctalValue(const s: string; var value: TUInt32): boolean;
  function getDecimalValue(const s: string; var value: TUInt32): boolean;
  function getHexadecimalValue(const s: string; var value: TUInt32): boolean;
  function getCharacterValue(const s: string; var value: TChar): boolean;
  function getFloatValue(const s: string; var value: TFloat32): boolean;

implementation

  const
    C_CHAR_LITERAL_DELIMITER = '''';
    C_DECIMAL_DELIMITER = '.';
    C_NUMBER_SPACER = '_';
    C_HEX_PREFIX = '$';
    C_OCT_PREFIX = '#';
    C_DOUBLE_PREFIX_BASE = '0';
    C_DOUBLE_PREFIX_HEX = 'x';
    C_DOUBLE_PREFIX_OCT = 'o';
    C_DOUBLE_PREFIX_BIN = 'b';

  function getBinaryValue(const s: string; var value: TUInt32): boolean;
  var
    result, i, weight: TUInt32;
  begin
    value := 0;
    getBinaryValue := false;
    if (length(s)<3) then exit;
    if s[1]<>C_DOUBLE_PREFIX_BASE then exit;
    if s[2]<>C_DOUBLE_PREFIX_BIN then exit;
    weight := 1;
    for i := length(s) downto 3 do
    begin
      case s[i] of
        C_NUMBER_SPACER: continue;
        '1': inc(value, weight);
        '0': begin end;
      else
        exit
      end;
      weight := weight shl 1;
      if weight = 0 then exit;
    end;
    getBinaryValue := true;
  end;

  function getOctalValue(const s: string; var value: TUInt32): boolean;
  var
    result, i: TUInt32;
  begin
    value := 0;
    getOctalValue := false;
    if (length(s)<3) then exit;
    if s[1]<>C_DOUBLE_PREFIX_BASE then exit;
    if s[2]<>C_DOUBLE_PREFIX_OCT then exit;
    for i := 3 to length(s) do
    begin
      if (value and $E0000000) <> 0 then exit;
      case s[i] of
        C_NUMBER_SPACER: continue;
        '0'..'7': value := (value shl 3) or (ord(s[i])-ord('0'));
      else
        exit
      end;
    end;
    getOctalValue := true;
  end;
  
  function getDecimalValue(const s: string; var value: TUInt32): boolean;
  begin
  end;
  
  function getHexadecimalValue(const s: string; var value: TUInt32): boolean;
  var
    result, i: TUInt32;
  begin
    value := 0;
    getHexadecimalValue := false;
    if (length(s)<3) then exit;
    if s[1]<>C_DOUBLE_PREFIX_BASE then exit;
    if s[2]<>C_DOUBLE_PREFIX_HEX then exit;
    for i := 3 to length(s) do
    begin
      if (value and $F0000000) <> 0 then exit;
      case s[i] of
        C_NUMBER_SPACER: continue;
        '0'..'9': value := (value shl 4) or (ord(s[i])-ord('0'));
        'A'..'F': value := (value shl 4) or (10 + (ord(s[i])-ord('A')));
      else
        exit
      end;
    end;
    getHexadecimalValue := true;
  end;
  
  function getCharacterValue(const s: string; var value: TChar): boolean;
  begin
  end;
  
  function getFloatValue(const s: string; var value: TFloat32): boolean;
  begin
  end;  

end.