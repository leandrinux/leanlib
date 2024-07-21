{
  this unit performs the parsing of the data header in
  source code files, like definitions or variables
}
{
  unitname Unit

  2022 LRT
}
unit
  ldparser;

interface

  uses
    ascii, consts, utils, uclasses, types, locale, strings,
    uobject, uexc, lliteral, lcommon, lcbase, lsrccode, ltexts;

  const
    C_CLASS_ID_DATA_PARSER = $F012;
    C_DATA_HEADER = '.data';
    C_CODE_HEADER = '.code';
    C_DEFINE_KEYWORD = 'def';
    C_OPCODE_ADD_SYMBOL = 1001;

  type
    EDataType = (
      EDataTypeNone,
      EDataTypeDefinition
    );

    EDataParserState = (
      EDataParserStateStart,
      EDataParserHeader
    );

    PDataParser = ^TDataParser;
    TDataParser = object (TObject)
    public
      constructor initWithSourceCode(sourceCode: PSourceCode);
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      function isDone: boolean;
      procedure parse(var dataType: EDataType; var data: pointer);
    private
      _isDone: boolean;
      _state: EDataParserState;
      _sourceCode: PSourceCode;
      procedure fatalError(const str, args: string);
      procedure waitForDataHeader;
      procedure readHeaderElements;
      procedure addDefinitions(str: string);
    end;

implementation

  { TDataParser public }

  constructor TDataParser.initWithSourceCode(sourceCode: PSourceCode);
  begin
    inherited init;
    _sourceCode := sourceCode;
    _sourceCode^.retain;
    _isDone := false;
    _state := EDataParserStateStart;
  end;

  destructor TDataParser.done;
  begin
    _sourceCode^.release;
    inherited done;
  end;

  function TDataParser.getClassName: string;
  begin
    getClassName := 'TDataParser';
  end;

  function TDataParser.getClassId: word;
  begin
    getClassId := C_CLASS_ID_DATA_PARSER;
  end;

  function TDataParser.isDone: boolean;
  begin
    isDone := _isDone;
  end;

  procedure TDataParser.parse(var dataType: EDataType; var data: pointer);
  begin
    case _state of
      EDataParserStateStart: waitForDataHeader;
      EDataParserHeader: readHeaderElements;
    end;
  end;

  { TDataParser private }

  procedure TDataParser.waitForDataHeader;
  var
    str: string;
  begin
    str := trim(_sourceCode^.readLine);
    if _sourceCode^.isReadComplete or (str = C_CODE_HEADER) then 
      _isDone := true
    else if (length(str)=0) or (str[1]='#') then begin end 
    else if str = C_DATA_HEADER then 
      _state := EDataParserHeader
    else 
      msg(EMsgFatal, C_STR_EXPECTED_DATA, intToStr(_sourceCode^.lineNumber));;
  end;

  procedure TDataParser.readHeaderElements;
  var
    str: string;
  begin
    str := trim(_sourceCode^.readLine);
    if str = C_CODE_HEADER then _isDone := true
    else if (length(str)=0) or (str[1]='#') then begin end 
    else if beginsWith(str, C_DEFINE_KEYWORD + ' ') then addDefinitions(str)
    else 
      fatalError(C_STR_ERR_UNRECOGNIZED_DATA_ELEMENT, str);
  
  end;

  procedure TDataParser.addDefinitions(str: string);  

    procedure addDefinition(str: string);
    var
      i: byte;
      symbol: PSymbol;
      stringValue: TString30;
      success: boolean;
    begin
      if getDelegate = nil then exit;
      i := pos('=', str);
      if (i > 0) then
      begin
        stringValue := trim(copy(str, i+1, length(str)-i));
        symbol := new(PSymbol, init);
        symbol^.name := trim(copy(str, 1, i-1));
        success := any2int(stringValue, symbol^.value);
        if not success then fatalError(C_STR_ERR_UNRECOGNIZABLE_SYMBOL, stringValue);
        sendMessageWithData(C_OPCODE_ADD_SYMBOL, getDelegate, symbol, 0);
        symbol^.release;
      end else
        fatalError(C_STR_ERR_EXPECTED_EQUAL, str);
    end;

  var
    a, b: byte;
    def: string;
  begin
    a := length(C_DEFINE_KEYWORD) + 1;
    b := a;
    while (a<length(str)) do
    begin
      while (b<length(str)) and (str[b]<>',') do inc(b);
      def := copy(str, a+1, b-a);
      def := trimChars(def, C_TRIM_CHARS + [',']);
      addDefinition(def);
      a := b;
      b := b + 1;
    end;
  end;

  procedure TDataParser.fatalError(const str, args: string);
  begin
    msg(EMsgFatal, str, intToStr(_sourceCode^.lineNumber) + C_NULL + args);
  end;

  { Other }

end.
