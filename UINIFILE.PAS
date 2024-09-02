{
  uinifile Unit
  Reads INI files
  2022 LRT
}
unit
  uinifile;

interface

  uses
    consts, utils, uexc, uclasses, types, locale, uobject,
    strings, ustream, udict;

  type
    PINIFile = ^TINIFile;
    TINIFile = object (TObject)
    public
      constructor initWithFile(filename: string);
      constructor initWithStream(stream: PStream);
      function getValue(path: string): string;
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _root, _current: PDictionary;
      procedure parseLine(s: string);
    end;

implementation

  const
    C_COMMENT_MARKER = '#';
    C_LABEL_START = '[';
    C_LABEL_END = ']';
    C_KEY_VALUE_DELIMITER = '=';

  { TINIFile public }

  constructor TINIFile.initWithFile(filename: string);
  var
    s: string;
    handle: text;
  begin
    inherited init;
    _root := new(PDictionary, init);
    _current := _root;
    assign(handle, filename);
    {$I-} reset(handle); {$I+}
    iassert(IOResult = 0, @self, 0, S_ERR_RESOURCE_NOT_FOUND);
    while not seekeof(handle) do
    begin
      readln(handle, s);
      parseLine(s);
    end;
    close(handle);
  end;

  constructor TINIFile.initWithStream(stream: PStream);
  begin
    inherited init;
    _root := new(PDictionary, init);
    _current := _root;
    while not stream^.isEOF do parseLine(stream^.readln);
  end;

  destructor TINIFile.done;
  begin
    _root^.release;
    inherited done;
  end;

  function TINIFile.getValue(path: string): string;
  begin
    getValue := _root^.getStringWithPath(path, '');
  end;

  function TINIFile.getClassName: string;
  begin
    getClassName := 'TINIFile';
  end;

  function TINIFile.getClassId: word;
  begin
    getClassId := C_CLASS_ID_INIFile;
  end;

  { TINIFile private }

  procedure TINIFile.parseLine(s: string);
  var
    len, i: byte;

    procedure skipSpaces;
    begin
      while (s[i] = ' ') and (i <= len) do inc(i);
    end;

    procedure moveUntil(ch: char);
    begin
      while (s[i] <> ch) and (i <= len) do inc(i);
    end;

    procedure updateGroup;
    var
      pfrom: byte;
      groupName: string32;
    begin
      pFrom := i + 1;
      moveUntil(C_LABEL_END);
      if (i > len) then exit; { malformed line, skipping }
      groupName := subString(s, pFrom, i - pFrom);
      _current := New(PDictionary, init);
      _root^.addObject(_current, groupName);
      _current^.release;
    end;

    procedure addValue;
    var
      p: byte;
      key: string32;
      value: string;
    begin
      p := Pos(C_KEY_VALUE_DELIMITER, s);
      if p = 0 then exit; { discard malformed line }
      key := SubString(s, 1, p - 1);
      value := SubString(s, p + 1, len - p);
      _current^.addString(value, key);
    end;

  begin
    len := length(s);
    i := 1;
    skipSpaces;
    if (i > len) then exit; { ignore empty line }
    if (s[i] = C_COMMENT_MARKER) then exit; { ignore comments }
    if (s[i] = C_LABEL_START) then updateGroup else addValue;
  end;

  { Other }

end.