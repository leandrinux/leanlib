{
  ujson Unit
  A JSON file reader that returns a hierachy of objects
  2022 LRT
}
unit
  ujson;

interface

  uses
    ascii, consts, utils, uexc, uclasses, types, locale, uobject, ustream,
    udict, ulist, ustring, unumber;

  type
    PJsonReader = ^TJsonReader;
    TJsonReader = object (TObject)
    public
      function open(stream: PStream): PObject;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _stream: PStream;
      function readNext: char;
      function parseObject: PObject;
      function parseNumber: PNumber;
      function parseString: PString;
      function parseDict: PDictionary;
      function parseList: PList;
      function exceptionStr: string;
    end;

implementation

  const
    C_BUFFER_SIZE = 1024;
    C_SKIPPABLE_CHARS = [#0, ' ', C_LF, C_CR];

  { TJsonReader public }

  function TJsonReader.open(stream: PStream): PObject;
  begin
    open := nil;
    _stream := stream;
    open := parseObject;
    _stream := nil;
  end;

  function TJsonReader.getClassName: string;
  begin
    getClassName := 'TJsonReader';
  end;

  function TJsonReader.getClassId: word;
  begin
    getClassId := C_CLASS_ID_JsonReader;
  end;

  { TJsonReader private }

  function TJsonReader.readNext: char;
  var
    result: word;
    ch: char;
  begin
    ch := #0;
    while not _stream^.isEOF and (ch in C_SKIPPABLE_CHARS) do
      _stream^.read(@ch, 1, result);
    if result = 1 then readNext := ch else readNext := #0;
  end;

  function TJsonReader.parseObject: PObject;
  var
    ch: char;
  begin
    ch := readNext;
    _stream^.seek(_stream^.getPosition-1);
    case ch of
      '0'..'9', '-': parseObject := parseNumber;
      '"': parseObject := parseString;
      '{': parseObject := parseDict;
      '[': parseObject := parseList;
    else
      raise(@self, 0, exceptionStr);
    end;
  end;

  function TJsonReader.parseNumber: PNumber;
  var
    ch: char;
    str: string32;
    result: word;
    value: longint;
    code: integer;
    number: PNumber;
  begin
    str := '';
    _stream^.read(@ch, 1, result);
    if ch in ['-', '0'..'9'] then
    begin
      str := str + ch;
      _stream^.read(@ch, 1, result);
    end;
    while not _stream^.isEOF and (ch in ['0'..'9']) do
    begin
      str := str + ch;
      _stream^.read(@ch, 1, result);
    end;
    iassert(length(str)>0, @self, _stream^.getPosition, exceptionStr);
    _stream^.seek(_stream^.getPosition-1);
    val(str, value, code);
    iassert(code=0, @self, _stream^.getPosition, exceptionStr);
    number := new(PNumber, init);
    number^.setValue(value);
    parseNumber := number;
  end;

  function TJsonReader.parseString: PString;
  var
    ch: char;
    result: word;
    str: string;
    pStr: PString;
  begin
    ch := readNext;
    iassert(ch = '"', @self, _stream^.getPosition, exceptionStr);
    _stream^.read(@ch, 1, result);
    str := '';
    while not _stream^.isEOF and (ch <> '"') do
    begin
      str := str + ch;
      _stream^.read(@ch, 1, result);
    end;
    iassert(ch = '"', @self, _stream^.getPosition, exceptionStr);
    pStr := new(PString, init);
    pStr^.setValue(str);
    parseString := pStr;
  end;

  function TJsonReader.parseDict: PDictionary;
  var
    ch: char;
    keyStr: TDictionaryKey;
    result: word;
    dict: PDictionary;
    obj: PObject;
  begin
    iassert(readNext = '{', @self, _stream^.getPosition, exceptionStr);
    dict := new(PDictionary, init);
    repeat
      keyStr := '';
      ch := #0;
      while not _stream^.isEOF and (ch in C_SKIPPABLE_CHARS) do
        _stream^.read(@ch, 1, result);
      while not _stream^.isEOF and (ch in ['A'..'Z','a'..'z','_']) do
      begin
        keyStr := keyStr + ch;
        _stream^.read(@ch, 1, result);
      end;
      iassert(length(keyStr) > 0, @self, _stream^.getPosition, exceptionStr);
      iassert(ch = ':', @self, _stream^.getPosition, exceptionStr);
      obj := parseObject;
      dict^.addObject(obj, keyStr);
      obj^.release;
      ch := readnext;
      iassert(ch in [',', '}'], @self, _stream^.getPosition, exceptionStr);
    until ch = '}';
    parseDict := dict;
  end;

  function TJsonReader.parseList: PList;
  var
    ch: char;
    list: PList;
    obj: PObject;
  begin
    iassert(readNext = '[', @self, _stream^.getPosition, exceptionStr);
    list := new(PList, init);
    repeat
      obj := parseObject;
      list^.addObject(obj);
      obj^.release;
      ch := readnext;
      iassert(ch in [',', ']'], @self, _stream^.getPosition, exceptionStr);
    until ch = ']';
    parseList := list;
  end;

  function TJsonReader.exceptionStr: string;
  begin
    exceptionStr := S_ERR_INVALID_JSON_FILE + ' (pos:' + inttostr(_stream^.getPosition) + ')';
  end;

  { Other }

end.