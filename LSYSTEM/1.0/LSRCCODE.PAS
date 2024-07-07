{
  An object that represents the entirety of the source code to
  be compiled. Keeps track of the current position (line and character)
  while also allowing to look ahead one character in advance
}
unit
  lsrccode;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ustream, 
    lcbase;

  const
    C_CLASS_ID_SourceCode = $F010;

  type
    PSourceCode = ^TSourceCode;
    TSourceCode = object (TObject)
    public
      constructor initWithStream(stream: PStream);
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure readChar(var current, lookAhead: char);
      function isValid: boolean;
      function isReadComplete: boolean;
      function lineNumber: word;
      function linePosition: word;
    private
      _sourceCode: PChar;          { start of the full source code in memory }
      _sourceCodeSize: word;       { how big the source code is }
      _isValid: boolean;           { whether it was able to read the entire code succesfully }
      _sourcePos: PChar;           { pointer to the current position in the source code }
      _sourceCount: word;          { how many bytes of the source code we've read }
      _lineNumber: word;           { what is the current source code line }
      _linePosition: word;         { what is the current character within the current line }
    end;

implementation

  { TSourceCode public }

  constructor TSourceCode.initWithStream(stream: PStream);
  var 
    bytesRead: longint;
  begin
    inherited init;
    _sourceCodeSize := stream^.getSize;
    getMem(_sourceCode, _sourceCodeSize);
    bytesRead := stream^.read(_sourceCode, _sourceCodeSize);
    _isValid := bytesRead = _sourceCodeSize;
    _sourcePos := _sourceCode;
    _sourceCount := 0;
    _lineNumber := 0;
    _linePosition := 1;
  end;

  destructor TSourceCode.done;
  begin
    if _sourceCodeSize > 0 then freeMem(_sourceCode, _sourceCodeSize);
    inherited done;
  end;

  function TSourceCode.getClassName: string;
  begin
    getClassName := 'TSourceCode';
  end;

  function TSourceCode.getClassId: word;
  begin
    getClassId := C_CLASS_ID_SourceCode;
  end;

  procedure TSourceCode.readChar(var current, lookAhead: char);
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
      if _sourceCount = _sourceCodeSize then  
        lookAhead := #0
      else
        lookAhead := _sourcePos^;
    end;
  end;

  function TSourceCode.isValid: boolean;
  begin
    isValid := _isValid;
  end;

  function TSourceCode.isReadComplete: boolean;
  begin
    isReadComplete := _sourceCodeSize = _sourceCount;
  end;

  function TSourceCode.lineNumber: word;
  begin
    lineNumber := _lineNumber;
  end;

  function TSourceCode.linePosition: word;
  begin
    linePosition := _linePosition;
  end;

end.