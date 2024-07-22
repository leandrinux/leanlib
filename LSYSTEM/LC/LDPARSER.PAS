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
    C_DELEGATE_ADD_VARIABLE = 1001;

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
          writeln('EStateStart');
          token := '';
          state := EStateSkipSpacesBeforeType;
          ch := _sourceCode^.readChar;
        end;

        EStateSkipSpacesBeforeType: 
        begin
          writeln('EStateSkipSpacesBeforeType ', ch);
          if not (ch in C_SPACING_CHARS) then 
            state := EStateGetSymbolType
          else
            ch := _sourceCode^.readChar;
        end;

        EStateGetSymbolType:
        begin
          writeln('EStateGetSymbolType ', ch);
          if ch in ['a'..'z'] then
            token := token + ch
          else if ch in C_SPACING_CHARS then
          begin
            writeln('token: ', token);
            state := EStateSkipSpacesBeforeName;
            if token = C_KEYWORD_DEFINITION then
              symbolType := ESymbolTypeDefinition
            else if token = C_KEYWORD_VARIABLE then
              symbolType := ESymbolTypeVariable
            else 
              state := EStateFailed;
            writeln('symbolType: ', ord(symbolType));
            token := '';
          end;
          ch := _sourceCode^.readChar;
        end;

        EStateSkipSpacesBeforeName: 
        begin
          writeln('EStateSkipSpacesBeforeName ', ch);
          if not (ch in C_SPACING_CHARS) then 
            state := EStateGetSymbolName
          else 
            ch := _sourceCode^.readChar;
        end;

        EStateGetSymbolName:
        begin
          writeln('EStateGetSymbolName ', ch);
          if ch in C_IDENTIFIER_CHARS then
            token := token + ch
          else if ch in (C_SPACING_CHARS) then
          begin end else if ch in [':', '='] then
          begin 
            symbolName := token;
            token := '';
            writeln('symbolName:', symbolName);
            if (ch = ':') and (symbolType = ESymbolTypeVariable) then
              state := EStateSkipSpacesBeforeVarType
            else if (ch = '=') and (symbolType = ESymbolTypeDefinition) then
              state := EStateSkipSpacesBeforeDefinitionValue
            else if ch in [':', '='] then
              state := EStateFailed;
          end;
          ch := _sourceCode^.readChar;          
        end;

        EStateSkipSpacesBeforeDefinitionValue:
        begin
          writeln('EStateSkipSpacesBeforeDefinition ', ch);
          if not (ch in C_SPACING_CHARS) then 
            state := EStateGetDefinitionValue
          else
            ch := _sourceCode^.readChar;
        end;

        EStateGetDefinitionValue:
        begin
          writeln('EStateGetDefinition ', ch);
          if ch in (C_SPACING_CHARS + [',']) then
          begin
            value := token;
            token := '';
            writeln('SET DEFINITION "', symbolName,'" WITH VALUE "', value, '"');
            readln;
            state := EStateSkipSpacesAfterDefinition
          end else begin
            if ch in C_IDENTIFIER_CHARS then
              token := token + ch
            else ;
            ch := _sourceCode^.readChar;
          end;
        end;

        EStateSkipSpacesAfterDefinition:
        begin
          writeln('EStateSkipSpacesAfterDefinition ', ch);
          if (ch in C_SPACING_CHARS) then 
            ch := _sourceCode^.readChar
          else
            if ch = ',' then
              state := EStateSkipSpacesBeforeName
            else
              state := EStateSkipSpacesBeforeType;
        end;

        EStateSkipSpacesBeforeVarType: 
        begin
          writeln('EStateSkipSpacesBeforeVarType ', ch);
          if not (ch in C_SPACING_CHARS) then 
            state := EStateGetVarType
          else
            ch := _sourceCode^.readChar;
        end;

        EStateGetVarType:
        begin
          writeln('EStateGetVarType ', ch);
          if ch in C_IDENTIFIER_CHARS then
            token := token + ch
          else if ch in (C_SPACING_CHARS + ['=']) then
          begin
            varType := token;
            token := '';
            writeln('varType: ', varType);
            state := EStateSkipSpacesAfterVarType
          end;
          ch := _sourceCode^.readChar;
        end;

        EStateSkipSpacesAfterVarType:
        begin
          writeln('EStateSkipSpacesAfterVarType ', ch);
          if (ch in C_SPACING_CHARS) then 
            ch := _sourceCode^.readChar
          else
            if ch = '=' then
              state := EStateSkipSpacesBeforeVarValue
            else begin
              writeln('SET VARIABLE ', symbolName, ' of type ', varType, ' and no value ');
              readln;
              state := EStateSkipSpacesBeforeType;
            end;
        end;

        EStateSkipSpacesBeforeVarValue:
        begin
          writeln('EStateSkipSpacesBeforeVarValue ', ch);
          if (ch in [C_SPACE, C_TAB, '=']) then
          begin 
            ch := _sourceCode^.readChar;
          end else if (ch in [C_CR, C_LF, ',']) then
          begin
            value := token;
            token := '';
            writeln('varValue:', value);
            writeln('SET VARIABLE ', symbolName, ' of type ', varType, ' and value ', value);
            readln;
            state := EStateSkipSpacesAfterVarValue
          end else 
          begin
            token := token + ch;
            ch := _sourceCode^.readChar;
          end;
          
        end;

        EStateSkipSpacesAfterVarValue:
        begin
          writeln('EStateSkipSpacesAfterVarValue ', ch);
          if (ch in C_SPACING_CHARS) then 
            ch := _sourceCode^.readChar
          else
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

  { Other }

end.
