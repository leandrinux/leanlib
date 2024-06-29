unit
  lbuilder;

interface

  uses
    consts, utils, types, locale, math, uclasses,
    uobject, uexc, ustream, ufstream, ucstream, ustdout,
    lcommon, lcbase;

  type

    TSentence = record
      labelName: TString30;
      operationName: TString30;
      param0: TString30;
      param1: TString30;
    end;

    PBuilder = ^TBuilder;
    TBuilder = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      procedure setSourceStream(stream: PStream);
      procedure setSourceFileStream(filename: string);
      procedure setMessageStream(stream: PStream);
      procedure setStandardMessageOutput;
      procedure build;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _source: PStream;            { stream used to read the source code }
      _message: PStream;           { stream used by the compiler to output progress messages }
      _nestedCommentBlocks: byte;  { how many nested comment blocks we've counted so far }
      _sourceCode: PChar;          { start of the full source code in memory }
      _sourceCodeSize: word;       { how big the source code is }
      _sourcePos: PChar;           { pointer to the current position in the source code }
      _sourceCount: word;          { how many bytes of the source code we've read }
      _lineNumber: word;           { what is the current source code line }
      _linePosition: word;         { what is the current character within the current line }
      function loadSourceCode: boolean;
      procedure readChar(var current, lookAhead: char);
      procedure readSentence(var sentence: TSentence);
    end;

  const
    C_CLASS_ID_BUILDER = $F00F;

implementation
 
  { TBuilder public }

  constructor TBuilder.init;
  begin
    inherited init;
    _source := nil;
    _message := nil;
    _sourceCode := nil;
    _sourceCodeSize := 0;
  end;

  destructor TBuilder.done;
  begin
    if _sourceCodeSize > 0 then freeMem(_sourceCode, _sourceCodeSize);
    if _source<>nil then _source^.release;
    if _message<>nil then _message^.release;
    inherited done;
  end;

  function TBuilder.getClassName: string;
  begin
    getClassName := 'TBuilder';
  end;

  function TBuilder.getClassId: word;
  begin
    getClassId := C_CLASS_ID_BUILDER;
  end;

  procedure TBuilder.build;
  var
    sentence: TSentence;
  begin
    _message^.writeln('[-] Building');
    _nestedCommentBlocks := 0;
    if loadSourceCode then
    begin
      while _sourceCount < _sourceCodeSize do
      begin
        readSentence(sentence);
      end;
    end else 
      raise('Could not read source code');
  end;

  procedure TBuilder.setSourceStream(stream: PStream);
  begin
    if _source<>nil then _source^.release;
    _source := stream;
    _source^.retain;
  end;

  procedure TBuilder.setSourceFileStream(filename: string);
  var
    fileStream: PFileStream;
  begin
    fileStream := new(PFileStream, initWithPath(filename, EFileReadOnly));
    setSourceStream(fileStream);
  end;

  procedure TBuilder.setMessageStream(stream: PStream);
  begin
    if _message<>nil then _message^.release;
    _message := stream;
    _message^.retain;
  end;

  procedure TBuilder.setStandardMessageOutput;
  var
    stream: PStdOutput;
  begin
    stream := new(PStdOutput, init);
    setMessageStream(stream);
  end;

  { TBuilder private }

  function TBuilder.loadSourceCode: boolean;
  var 
    result: boolean;
  begin
    if _source^.getSize > $FFFF then 
      result := false
    else begin
      _sourceCodeSize := _source^.getSize;
      getMem(_sourceCode, _sourceCodeSize);
      _source^.read(_sourceCode, _sourceCodeSize);
      writeln('[-] ',_sourceCodeSize, ' bytes of source code read');
      _sourcePos := _sourceCode;
      _sourceCount := 0;
      result := true;
    end;
    loadSourceCode := result;
  end;

  procedure TBuilder.readChar(var current, lookAhead: char);
  var
    next: PChar;
  begin
    if _sourceCount = _sourceCodeSize then  
    begin
      current := #0;
      lookAhead := #0;
    end else
    begin
      current := _sourcePos^;
      inc(_sourcePos); 
      inc(_sourceCount);
      if current = C_LF then
      begin
        inc(_lineNumber);
        _linePosition := 1;
      end;

      if ord(current)>30 then write(current, ' ');
      write(ord(current), ': ');

      if _sourceCount = _sourceCodeSize then  
        lookAhead := #0
      else begin
        next := _sourcePos;
        inc(next);
        lookAhead := next^;
      end;
    end;
  end;

  procedure TBuilder.readSentence(var sentence: TSentence);
  type
    EState = (
      EStateStart,
      EStateSkipSpaces,
      EStateReadOperationOrLabel,
      EStateReadOperation,
      EStateReadFirstParam,
      EStateReadSecondParam,
      EStateSuccess,
      EStateFailure
    );
  var
    ch, lookAhead: char;
    state: EState;
    nextState: EState;
    token: string;
    errorMessage: string;
  begin
    state := EStateStart;
    while (state <> EStateSuccess) and (state <> EStateFailure) do
    begin
      readln;
      case state of
        EStateStart:
        begin
          writeln('EStateStart');
          errorMessage := '';
          token := '';
          state := EStateSkipSpaces;
          nextState := EStateReadOperationOrLabel;
        end;

        EStateSkipSpaces:
        begin
          writeln('EStateSkipSpaces');
          readChar(ch, lookAhead);
          if lookAhead<>' ' then state := nextState;
        end;

        EStateReadOperationOrLabel:
        begin
          writeln('EStateReadOperationOrLabel');
          readChar(ch, lookAhead);
          case ch of
            C_LF, C_CR: begin end;
            ':': begin
              sentence.labelName := token;
              token := '';
              state := EStateSkipSpaces;
              nextState := EStateReadOperation;
            end;
            ' ': begin
              sentence.labelName := '';
              sentence.operationName := token;
              token := '';
              state := EStateReadFirstParam;
            end;
          else
            token := token + ch;
          end;
        end;

        EStateReadOperation:
        begin
          writeln('EStateReadOperation');
          readChar(ch, lookAhead);
          case ch of
            C_LF, C_CR: begin end;
            ' ': begin
              sentence.operationName := token;
              token := '';
              state := EStateSkipSpaces;
              nextState := EStateReadFirstParam;
            end;
          else
            token := token + ch;
          end;
        end;

        EStateReadFirstParam:
        begin
          writeln('EStateReadFirstParam');
          readChar(ch, lookAhead);
          case ch of
            C_LF, C_CR: begin end;
            ' ': begin
              sentence.param0 := token;
              token := '';
              state := EStateSkipSpaces;
              nextState := EStateReadSecondParam;
            end;
          else
            token := token + ch;
          end;
        end;

        EStateReadSecondParam:
        begin
          writeln('EStateReadSecondParam');
          readChar(ch, lookAhead);
          case ch of
            C_LF: begin end;
            C_CR, #0: begin
              sentence.param1 := token;
              token := '';
              state := EStateSuccess;
            end;
          else
            token := token + ch;
          end;
        end;
      end;
    end;
    
    case state of
      EStateSuccess:
      begin
        writeln('EStateSuccess');
        with sentence do
        begin
          write('label:', labelName);
          write(' operation:', operationName);
          write(' first:', param0);
          write(' second:', param1);
        end;
      end;

      EStateFailure:
      begin
        writeln('EStateFailure');
      end;
    end;
  end;

end.
