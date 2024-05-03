unit
  lcparser;

interface

  uses 
    uobject, ustream, lcommon;

  type
    ELiteralType = (
      ELiteralNone,
      ELiteralChar,
      ELiteralInteger,
      ELiteralFloat
    );

    PTextParser = ^TTextParser;
    TTextParser = object (TObject)
    public
      constructor init;
      constructor initWithStream(stream: PStream);
      destructor done; virtual;
      function isLiteralType(var str: string): ELiteralType;
      function parseLiteral(var str: string): TUInt32;
    private
      _stream: PStream;
    end;  

implementation

  const
    C_CHAR_LITERAL_DELIMITER = '''';
    C_DECIMAL_DELIMITER = '.';

  constructor TTextParser.init;
  begin
    inherited init;
    _stream := nil;
  end;

  constructor TTextParser.initWithStream(stream: PStream);
  begin
    inherited init;
    _stream := stream;
    _stream^.retain;
  end;

  destructor TTextParser.done;
  begin
    if _stream <> nil then _stream^.release;
    inherited done;
  end;

  function TTextParser.isLiteralType(var str: string): ELiteralType;
  var
    i: byte;
  begin
    { set default output value }
    isLiteralType := ELiteralNone;

    if length(str)=0 then exit;

    { test for character }
    if (length(str) = 3) 
       and (str[1] = C_CHAR_LITERAL_DELIMITER)
       and (str[3] = C_CHAR_LITERAL_DELIMITER) then
    begin
      isLiteralType := ELiteralChar;
      exit;
    end;

    { test for integer }
    if str[1] in ['+', '-'] then
      if length(str) < 2 then
        exit
      else
        i := 2
    else
      i := 1;

    while (i < length(str)) and (str[i] in ['0'..'9']) do inc(i);
    if i = length(str) then
    begin
      if (str[i] in ['0'..'9']) then isLiteralType := ELiteralInteger;
      exit;
    end;

    { test for float }
    if (i = 1) or (str[i] <> C_DECIMAL_DELIMITER) then exit;
    inc(i);
    if i > length(str) then exit;
    while (i < length(str)) and (str[i] in ['0'..'9']) do inc(i);
    if (i = length(str)) and (str[i] in ['0'..'9']) then
      isLiteralType := ELiteralFloat;

  end;

  function TTextParser.parseLiteral(var str: string): TUInt32;
  begin
  end;

end.