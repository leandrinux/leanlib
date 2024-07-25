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
    
    C_DELEGATE_ADD_DEFINITION = 1001;
    C_DELEGATE_ADD_VARIABLE = 1002;

  type
    PDataParser = ^TDataParser;
    TDataParser = object (TObject)
    public
      constructor initWithSourceCode(sourceCode: PSourceCode);
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure parse;
    private
      _sourceCode: PSourceCode;
      procedure fatalError(const str, args: string);
      procedure addSymbol(const name: string; kind: ESymbolKind; bitSize: byte; stringValue: TString30);
      function getBitSizeFromVarType(varType: TString30): byte;
    end;

implementation

  { TDataParser public }

  constructor TDataParser.initWithSourceCode(sourceCode: PSourceCode);
  begin
    inherited init;
    _sourceCode := sourceCode;
    _sourceCode^.retain;
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

  procedure TDataParser.parse;
  type
    EParserState = (
      EStateStart,
      EStateSkipSpacesBeforeType,
      EStateGetSymbolType,
      EStateSkipSpacesBeforeName,
      EStateGetSymbolName,
      EStateSkipSpacesBeforeVarType,
      EStateGetVarType,
      EStateSkipSpacesBeforeDefinitionValue,
      EStateGetDefinitionValue,
      EStateSkipSpacesAfterDefinition,
      EStateSkipSpacesAfterVarType,
      EStateSkipSpacesBeforeVarValue,
      EStateSkipSpacesAfterVarValue,
      EStateSuccess,
      EStateFailed
    );
    ESymbolType = (
      ESymbolTypeDefinition,
      ESymbolTypeVariable
    );
  const
    C_END_STATES = [EStateSuccess, EStateFailed];
    C_SPACING_CHARS = [C_SPACE, C_TAB, C_CR, C_LF];
    C_IDENTIFIER_CHARS = ['A'..'Z', 'a'..'z', '_', '0'..'9'];
    C_KEYWORD_DEFINITION = 'def';
    C_KEYWORD_VARIABLE = 'var';
  var
    state: EParserState;
    token: string;
    ch: char;
    symbolType: ESymbolType;
    symbolName: TString30;
    value: TString30;
    varType: TString30;
  begin
    state := EStateStart;
    while not (state in C_END_STATES) do
    begin
      case state of
        EStateStart:
        begin
          token := '';
          state := EStateSkipSpacesBeforeType;
{          _sourceCode^.readChar; }
          ch := _sourceCode^.currentChar;
        end;

        EStateSkipSpacesBeforeType: 
        begin
          if not (ch in C_SPACING_CHARS) then 
            state := EStateGetSymbolType
          else begin
            _sourceCode^.readChar;
            ch := _sourceCode^.currentChar;
          end;
        end;

        EStateGetSymbolType:
        begin
          if ch in ['a'..'z'] then
            token := token + ch
          else if ch in C_SPACING_CHARS then
          begin
            state := EStateSkipSpacesBeforeName;
            if token = C_KEYWORD_DEFINITION then
              symbolType := ESymbolTypeDefinition
            else if token = C_KEYWORD_VARIABLE then
              symbolType := ESymbolTypeVariable
            else 
              state := EStateFailed;
            token := '';
          end;
          if ch <> '.' then
          begin
            _sourceCode^.readChar;
            ch := _sourceCode^.currentChar;
          end else 
            state := EStateSuccess
        end;

        EStateSkipSpacesBeforeName: 
        begin
          if not (ch in C_SPACING_CHARS) then 
            state := EStateGetSymbolName
          else begin
            _sourceCode^.readChar;
            ch := _sourceCode^.currentChar;
          end;
        end;

        EStateGetSymbolName:
        begin
          if ch in C_IDENTIFIER_CHARS then
            token := token + ch
          else if ch in (C_SPACING_CHARS) then
          begin end else if ch in [':', '='] then
          begin 
            symbolName := token;
            token := '';
            if (ch = ':') and (symbolType = ESymbolTypeVariable) then
              state := EStateSkipSpacesBeforeVarType
            else if (ch = '=') and (symbolType = ESymbolTypeDefinition) then
              state := EStateSkipSpacesBeforeDefinitionValue
            else if ch in [':', '='] then
              state := EStateFailed;
          end;
          _sourceCode^.readChar;
          ch := _sourceCode^.currentChar;
        end;

        EStateSkipSpacesBeforeDefinitionValue:
        begin
          if not (ch in C_SPACING_CHARS) then 
            state := EStateGetDefinitionValue
          else begin
            _sourceCode^.readChar;
            ch := _sourceCode^.currentChar;
          end;
        end;

        EStateGetDefinitionValue:
        begin
          if ch in (C_SPACING_CHARS + [',']) then
          begin
            value := token;
            token := '';
            { writeln('SET DEFINITION "', symbolName,'" WITH VALUE "', value, '"'); }
            addSymbol(symbolName, ESymbolDefinition, 32, value);
            state := EStateSkipSpacesAfterDefinition
          end else begin
            if ch in C_IDENTIFIER_CHARS then
              token := token + ch
            else ;
            _sourceCode^.readChar;
            ch := _sourceCode^.currentChar;
          end;
        end;

        EStateSkipSpacesAfterDefinition:
        begin
          if (ch in C_SPACING_CHARS) then 
          begin
            _sourceCode^.readChar;
            ch := _sourceCode^.currentChar;
          end else
            if ch = ',' then
              state := EStateSkipSpacesBeforeName
            else
              state := EStateSkipSpacesBeforeType;
        end;

        EStateSkipSpacesBeforeVarType: 
        begin
          if not (ch in C_SPACING_CHARS) then 
            state := EStateGetVarType
          else begin
            _sourceCode^.readChar;
            ch := _sourceCode^.currentChar;
          end;
        end;

        EStateGetVarType:
        begin
          if ch in C_IDENTIFIER_CHARS then
            token := token + ch
          else if ch in (C_SPACING_CHARS + ['=']) then
          begin
            varType := token;
            token := '';
            state := EStateSkipSpacesAfterVarType
          end;
          _sourceCode^.readChar;
          ch := _sourceCode^.currentChar;
        end;

        EStateSkipSpacesAfterVarType:
        begin
          if (ch in C_SPACING_CHARS) then 
          begin
            _sourceCode^.readChar;
            ch := _sourceCode^.currentChar;
          end else
            if ch = '=' then
              state := EStateSkipSpacesBeforeVarValue
            else begin
              { writeln('SET VARIABLE ', symbolName, ' of type ', varType, ' and no value '); }
              addSymbol(symbolName, ESymbolVariable, getBitSizeFromVarType(varType), '');
              state := EStateSkipSpacesBeforeType;
            end;
        end;

        EStateSkipSpacesBeforeVarValue:
        begin
          if (ch in [C_SPACE, C_TAB, '=']) then
          begin 
            _sourceCode^.readChar;
            ch := _sourceCode^.currentChar;
          end else if (ch in [C_CR, C_LF, ',']) then
          begin
            value := token;
            token := '';
            { writeln('SET VARIABLE ', symbolName, ' of type ', varType, ' and value ', value); }
            addSymbol(symbolName, ESymbolVariable, getBitSizeFromVarType(varType), value);
            state := EStateSkipSpacesAfterVarValue
          end else 
          begin
            token := token + ch;
            _sourceCode^.readChar;
            ch := _sourceCode^.currentChar;
          end;
          
        end;

        EStateSkipSpacesAfterVarValue:
        begin
          if (ch in C_SPACING_CHARS) then 
          begin
            _sourceCode^.readChar;
            ch := _sourceCode^.currentChar;
          end else
            if ch = ',' then
              state := EStateSkipSpacesBeforeName
            else if ch = '.' then
              state := EStateSuccess
            else
              state := EStateSkipSpacesBeforeType;
        end;

      end;    
    end;
  end;

  { TDataParser private }

  procedure TDataParser.fatalError(const str, args: string);
  begin
    msg(EMsgFatal, str, intToStr(_sourceCode^.lineNumber) + C_NULL + args);
  end;

  procedure TDataParser.addSymbol(const name: string; kind: ESymbolKind; bitSize: byte; stringValue: TString30);
  const
    C_SYMBOL_KIND_STR: array[ESymbolKind] of TString30 = ('label', 'definition', 'variable');
  var
    symbol: PSymbol;
    success: boolean;
    operation: word;
  begin
{
    write('add symbol "', name, '"');
    write(', kind: ', C_SYMBOL_KIND_STR[kind]);
    write(', bitSize: ', bitSize);
    write(', stringValue: ', stringValue);
    writeln;
}
    if getDelegate = nil then exit;
    symbol := new(PSymbol, init);
    symbol^.name := name;
    symbol^.kind := kind;
    symbol^.byteSize := bitSize shr 3;
    if stringValue = '' then stringValue := '0';
    success := any2int(stringValue, symbol^.value);
    if not success then fatalError(C_STR_ERR_UNRECOGNIZABLE_SYMBOL, stringValue);
    case kind of
      ESymbolDefinition, ESymbolLabel: 
        operation := C_DELEGATE_ADD_DEFINITION;
      ESymbolVariable: 
        operation := C_DELEGATE_ADD_VARIABLE;
    end;
    sendMessageWithData(operation, getDelegate, symbol, 0);
    symbol^.release;
  end;

  function TDataParser.getBitSizeFromVarType(varType: TString30): byte;
  begin
    if varType = 'byte' then
      getBitSizeFromVarType := 8
    else if varType = 'word' then
      getBitSizeFromVarType := 16
    else if varType = 'long' then
      getBitSizeFromVarType := 32
    else
      fatalError(C_STR_ERR_UNRECOGNIZABLE_DATA_TYPE, varType);
  end;
  { Other }

end.
