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
      function createFromStream(stream: PStream): PObject;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _stream: PStream;
      function readNext: char;
      function createObject: PObject;
      function createNumber: PNumber;
      function createBool: PNumber;
      function createString: PString;
      function createDict: PDictionary;
      function createList: PList;
      function exceptionStr: string;
    end;

implementation

  const
    C_SKIPPABLE_CHARS = [#0, ' ', C_LF, C_CR];
    C_DICTIONARY_KEY_CHARACTERS = ['A'..'Z','a'..'z','_','-'];

  { TJsonReader public }

  function TJsonReader.createFromStream(stream: PStream): PObject;
  begin
    createFromStream := nil;
    _stream := stream;
    createFromStream := createObject;
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
      result := _stream^.read(@ch, 1);
    if result = 1 then readNext := ch else readNext := #0;
  end;

  function TJsonReader.createObject: PObject;
  var
    ch: char;
  begin
    ch := readNext;
    _stream^.seek(_stream^.getPosition-1);
    case ch of
      '0'..'9', '-': createObject := createNumber;
      '"': createObject := createString;
      '{': createObject := createDict;
      '[': createObject := createList;
      'f', 't': createObject := createBool;
    else
      raise(@self, 0, exceptionStr);
    end;
  end;

  function TJsonReader.createNumber: PNumber;
  var
    ch: char;
    str: string32;
    result: word;
    value: longint;
    code: integer;
    number: PNumber;
  begin
    str := '';
    result := _stream^.read(@ch, 1);
    if ch in ['-', '0'..'9'] then
    begin
      str := str + ch;
      result := _stream^.read(@ch, 1);
    end;
    while not _stream^.isEOF and (ch in ['0'..'9']) do
    begin
      str := str + ch;
      result := _stream^.read(@ch, 1);
    end;
    iassert(length(str)>0, @self, _stream^.getPosition, exceptionStr);
    _stream^.seek(_stream^.getPosition-1);
    val(str, value, code);
    iassert(code=0, @self, _stream^.getPosition, exceptionStr);
    number := new(PNumber, init);
    number^.setValue(value);
    createNumber := number;
  end;

  function TJsonReader.createBool: PNumber;
  var
    ch: char;
    i: byte;
    expected: string8;
    value: PNumber;
  begin
    ch := readNext;
    iassert(ch in ['t', 'f'], @self, _stream^.getPosition, exceptionStr);
    if ch = 't' then expected := 'true' else expected := 'false';
    i := 2;
    while i <= length(expected) do
    begin
      ch := readNext;
      iassert(ch = expected[i], @self, _stream^.getPosition, exceptionStr);
      inc(i);
    end;
    value := new(PNumber, init);
    if expected[1] = 't' then value^.setValue(1) else value^.setValue(0);
    createBool := value;
  end;

  function TJsonReader.createString: PString;
  var
    ch: char;
    result: word;
    str: string;
    pStr: PString;
  begin
    ch := readNext;
    iassert(ch = '"', @self, _stream^.getPosition, exceptionStr);
    result := _stream^.read(@ch, 1);
    str := '';
    while not _stream^.isEOF and (ch <> '"') do
    begin
      str := str + ch;
      result := _stream^.read(@ch, 1);
    end;
    iassert(ch = '"', @self, _stream^.getPosition, exceptionStr);
    pStr := new(PString, init);
    pStr^.setValue(str);
    createString := pStr;
  end;

  function TJsonReader.createDict: PDictionary;
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
        result := _stream^.read(@ch, 1);
      iassert(ch = '"', @self, _stream^.getPosition, exceptionStr);
      result := _stream^.read(@ch, 1);
      while not _stream^.isEOF and (ch in C_DICTIONARY_KEY_CHARACTERS) do
      begin
        keyStr := keyStr + ch;
        result := _stream^.read(@ch, 1);
      end;
      iassert(ch = '"', @self, _stream^.getPosition, exceptionStr);
      result := _stream^.read(@ch, 1);
      iassert(length(keyStr) > 0, @self, _stream^.getPosition, exceptionStr);
      iassert(ch = ':', @self, _stream^.getPosition, exceptionStr);
      obj := createObject;
      dict^.addObject(obj, keyStr);
      obj^.release;
      ch := readnext;
      iassert(ch in [',', '}'], @self, _stream^.getPosition, exceptionStr);
    until ch = '}';
    createDict := dict;
  end;

  function TJsonReader.createList: PList;
  var
    ch: char;
    list: PList;
    obj: PObject;
  begin
    iassert(readNext = '[', @self, _stream^.getPosition, exceptionStr);
    list := new(PList, init);
    repeat
      obj := createObject;
      list^.addObject(obj);
      obj^.release;
      ch := readnext;
      iassert(ch in [',', ']'], @self, _stream^.getPosition, exceptionStr);
    until ch = ']';
    createList := list;
  end;

  function TJsonReader.exceptionStr: string;
  begin
    exceptionStr := S_ERR_INVALID_JSON_FILE + ' (pos:' + inttostr(_stream^.getPosition) + ')';
  end;

  { Other }

end.