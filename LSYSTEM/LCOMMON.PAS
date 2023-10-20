{
  LCommon Unit
  Common functions used by both the lsystem compiler and interpreter
  2023 LRT
}
unit
  lcommon;

interface

  {$P+} { enables compatibility between strings of different type }

  const
    C_SYSTEM_VERSION = '0.0.2';
    C_DEFAULT_MEMORY_SIZE = 2000;
    C_DEFAULT_STACK_SIZE = 200;
    C_INVALID_OPCODE = $FF;    
    C_INVALID_OPCODE_ID = '<ERR>';
    C_INSTRUCTION_COUNT = 28;  { total number of supported instructions }

    C_PARAMETER_TYPE_LITERAL  = 0;
    C_PARAMETER_TYPE_REGISTER = 1;
    C_PARAMETER_TYPE_ADDRESS  = 2;
    C_PARAMETER_TYPE_INDIRECT = 3;

  type
    TString4  = string[4];
    TString6  = string[6];
    TString7  = string[7];
    TString10 = string[10];

    PByte = ^byte;

    TMemoryAddress = 0 .. C_DEFAULT_MEMORY_SIZE - 1;

    PInstruction = ^TInstruction;
    TInstruction = packed record
      opcode: integer;
      param0: integer;
      param1: integer;
    end;

    PSystemState = ^TSystemState;
    TSystemState = record
      registers: array[6..15] of integer;
      ss, ds: TMemoryAddress;
      memory: array[TMemoryAddress] of integer;
    end;

    EErrorCode = (
      EErrorNone,
      EErrorWarning,
      EErrorFatal
    );

    ELogType = (
      ELogNone,
      ELogNormal,
      ELogHigh,
      ELogVerbose
    );

  const
    C_NULL_INSTRUCTION : TInstruction = (
      opcode: 0;
      param0: 0;
      param1: 0
    );

  function strToInt(s: TString7): integer;
  function decToInt(const s: TString6): integer;
  function hexToInt(const s: TString4): integer;
  function octToInt(const s: TString6): integer;
  function wordToHex(w: word): TString4;
  function wordToDec(w: word): TString6;
  procedure writeDecAddress(n: word);
  function shortintToDec(value: shortint): TString4;

  function loadState(var m: TSystemState; const filename: string): boolean;
  function saveState(var m: TSystemState; const filename: string): boolean;

  procedure strUpper(var str:string);
  function isValidHexNumber(s: TString4): boolean;
  function isValidRegister(s: TString4): boolean;

  procedure updateIndirect(var paramValue:integer; var paramType:byte; var systemState: TSystemState);

  procedure log(logType: ELogType; message: string);

implementation

  { 
    gets: a string with a literal number (including #, @ o $)
    returns: the integer value for that string 
  }
  function strToInt(s: TString7): integer;
  var c: char;
  begin
    c := s[1];
    delete(s, 1, 1);
    case c of
      '@': strToInt := octToInt(s);
      '$': strToInt := hexToInt(s);
      '#': strToInt := decToInt(s);
    end;
  end;

  {
    gets: a string with a literal hex number
    returns: the integer value for that string
  }
  function hexToInt(const s: TString4): integer;
  var
   n, p: word;
   i, v: byte;
  begin
    p := 1;
    n := 0;
    for i := ord(s[0]) downto 1 do
    begin
      v := ord(s[i]) and $0F;
      if ord(s[i]) shr 4=4 then v := v + 9;
      n := n + v * p;
      p := p * 16;
    end;
    hexToInt := n;
  end;

  {
    gets: a string with a literal octal number
    returns: the integer value for that string
  }
  function octToInt(const s: TString6): integer;
  var
    n, p: word;
    i, v: byte;
  begin
    p := 1;
    n := 0;
    for i:=ord(s[0]) downto 1 do
    begin
      n := n + (ord(s[i])-48) * p;
      p := p * 8;
    end;
    octToInt := n;
  end;

  {
    gets: a string with a literal decimal number
    returns: the integer value for that string
  }
  function decToInt(const s: TString6): integer;
  var
    a,c: integer;
  begin
    val(s,a,c);
    decToInt := a;
  end;

  {
    gets: a two byte unsigned value
    returns: A 4-char string with its hex representation
  }
  function wordToHex(w: word): TString4;
  var
    b: byte;
    s: TString4;
    n,m: word;
  begin
    m := $F000;
    s[0]:=#4;
    for b:=1 to 4 do
    begin
      n := (w and m) shr (4*(4-b));
      if n<10 then
        s[b] := chr(48+n)
      else
        s[b] := chr(55+n);
      m := m shr 4;
    end;
    wordToHex := s;
  end;

  function wordToDec(w: word): TString6;
  var
    returnValue: TString6;
  begin
    str(w, returnValue);
    wordToDec := returnValue;
  end;

  {
    writes a memory address in decimal including leading zeroes
  }
  procedure writeDecAddress(n: word);
    function zeroCount(n:word):byte; 
    begin
      zeroCount := 3;
      if n div 1000<>0 then zeroCount := 0
      else if n div 100<>0 then zeroCount := 1
      else if n div 10<>0 then zeroCount := 2;
    end;
  var
    i: byte;
  begin
    for i := 1 to zeroCount(n) do write('0');
    write(n);
  end;

  {
    saves the system state to a file
  }
  function saveState(var m: TSystemState; const filename: string): boolean;
  var
    f: file;
  begin
    {$I-}
    assign(f, filename);
    rewrite(f, 1);
    blockwrite(f, m, sizeof(m));
    close(f);
    {$I+}
    saveState := IOResult = 0;
  end;

  {
    loads from file the system state
  }
  function loadState(var m: TSystemState; const filename: string): boolean;
  var
    f: file;
  begin
    assign(f, filename);
    {$I-} reset(f, 1); {$I+}
    if IOResult = 0 then
    begin
      loadState := true;
      blockread(f, m, sizeof(m));
      close(f);
    end else
      loadState := false;
  end;

  { modifies the given string, changing it to uppercase }
  procedure strUpper(var str:string);
  var
    b: byte;
  begin
    for b := 1 to ord(str[0]) do str[b] := upcase(str[b]);
  end;

  { gets a string and determines if it's a valid hex number }
  function isValidHexNumber(s: TString4): boolean;
  var 
    b: boolean; 
    a: byte;
  begin
    b := true; 
    a := 1;
    while b and (a <= length(s)) do
    begin
      b := b and (s[a] in ['A'..'F', '0'..'9']);
      a := a + 1;
    end;
    isValidHexNumber := b;
  end;

  { gets a string an determines if it's a valid register name }
  function isValidRegister(s: TString4): boolean;
  begin
   isValidRegister := (length(s)=2) and (((s[1] in ['A'..'F']) and (s[2]='X')) or
     ((s[1] in ['S','B','I']) and (s[2]='P')) or (s='CC'));
  end;

  { converts an indirect param to a memory param }
  procedure updateIndirect(var paramValue:integer; var paramType:byte; var systemState: TSystemState);
  var 
    mask: word;
  begin
    paramType := C_PARAMETER_TYPE_ADDRESS;
    if paramValue < 0 then mask := $F000 else mask := $0000;
    with systemState do
      if (paramValue and $000F) in [6, 7] then
        paramValue := registers[paramValue and $000F] + ((paramValue shr 4) or mask) + ss
      else
        paramValue := registers[paramValue and $000F] + ((paramValue shr 4) or mask) + ds;
  end;

  procedure log(logType: ELogType; message: string);
  begin
    writeln('[-] ', message);
  end;

  function shortintToDec(value: shortint): TString4;
  var 
    resultValue: TString4;
  begin
    str(value, resultValue);
    shortintToDec := resultValue;
  end;

end.