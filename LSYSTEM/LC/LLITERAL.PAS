{$N+}

unit 
  lliteral;

interface

  uses
    lcommon;

  function any2int(const s: string; var value: TUInt32): boolean;
  function bin2int(const s: string; var value: TUInt32): boolean;
  function oct2int(const s: string; var value: TUInt32): boolean;
  function dec2int(const s: string; var value: TUInt32): boolean;
  function hex2int(const s: string; var value: TUInt32): boolean;
  function chr2int(const s: string; var value: TUInt32): boolean;
  function str2single(const s: string; var value: TFloat32): boolean;

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

  function any2int(const s: string; var value: TUInt32): boolean;
  var
    result: boolean;
  begin
    result := hex2int(s, value);
    if not result then result := oct2int(s, value);
    if not result then result := bin2int(s, value);
    if not result then result := dec2int(s, value);
    if not result then result := chr2int(s, value);
    if not result then result := str2single(s, TFloat32(value));
    any2int := result;
  end;

  function bin2int(const s: string; var value: TUInt32): boolean;
  var
    result, i, weight: TUInt32;
  begin
    value := 0;
    bin2int := false;
    if (length(s)<3) then exit;
    if s[1]<>C_DOUBLE_PREFIX_BASE then exit;
    if s[2]<>C_DOUBLE_PREFIX_BIN then exit;
    weight := 1;
    for i := length(s) downto 3 do
    begin
      if weight = 0 then exit;
      case s[i] of
        C_NUMBER_SPACER: continue;
        '1': inc(value, weight);
        '0': begin end;
      else
        exit
      end;
      weight := weight shl 1;
    end;
    bin2int := true;
  end;

  function oct2int(const s: string; var value: TUInt32): boolean;
  var
    result: TUInt32;
    i, prefixLength: byte;
    isSinglePrefix, isDoublePrefix: boolean;
  begin
    value := 0;
    oct2int := false;
    isSinglePrefix := (length(s) > 1) and (s[1] = C_OCT_PREFIX);
    isDoublePrefix := (length(s) > 2) and (s[1] = C_DOUBLE_PREFIX_BASE) and (s[2] = C_DOUBLE_PREFIX_OCT);
    if (not isSinglePrefix) and (not isDoublePrefix) then exit;
    if isSinglePrefix then prefixLength := 1 else prefixLength := 2;
    for i := prefixLength + 1 to length(s) do
    begin
      if (value and $E0000000) <> 0 then exit;
      case s[i] of
        C_NUMBER_SPACER: continue;
        '0'..'7': value := (value shl 3) or (ord(s[i])-ord('0'));
      else
        exit
      end;
    end;
    oct2int := true;
  end;
  
  function dec2int(const s: string; var value: TUInt32): boolean;
  var 
    clean: string;
    code: integer;
    i: byte;
  begin
    clean := '';
    for i := 1 to length(s) do if s[i]<>C_NUMBER_SPACER then clean := clean + s[i];
    val(clean, value, code);
    dec2int := code = 0;
  end;
  
  function hex2int(const s: string; var value: TUInt32): boolean;
  var
    result: TUInt32;
    i, prefixLength: byte;
    isSinglePrefix, isDoublePrefix: boolean;
  begin
    value := 0;
    hex2int := false;
    isSinglePrefix := (length(s) > 1) and (s[1] = C_HEX_PREFIX);
    isDoublePrefix := (length(s) > 2) and (s[1] = C_DOUBLE_PREFIX_BASE) and (s[2] = C_DOUBLE_PREFIX_HEX);
    if (not isSinglePrefix) and (not isDoublePrefix) then exit;
    if isSinglePrefix then prefixLength := 1 else prefixLength := 2;
    for i := prefixLength + 1 to length(s) do
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
    hex2int := true;
  end;
  
  function chr2int(const s: string; var value: TUInt32): boolean;
  begin
    chr2int := false;
    if length(s)<>3 then exit;
    if (s[1]<>C_CHAR_LITERAL_DELIMITER) or (s[3]<>C_CHAR_LITERAL_DELIMITER) then exit;
    value := ord(s[2]);
    chr2int := true;
  end;

  function str2single(const s: string; var value: TFloat32): boolean;
  var 
    clean: string;
    code: integer;
    i: byte;
  begin
    clean := '';
    for i := 1 to length(s) do if s[i]<>C_NUMBER_SPACER then clean := clean + s[i];
    val(clean, value, code);
    str2single := code = 0;
  end;

end.