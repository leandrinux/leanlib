{
  An object that represents the entirety of the source code to
  be compiled. Keeps track of the current position (line and character)
  while also allowing to look ahead one character in advance
}
unit
  lsrccode;

interface

  uses
    ascii, consts, utils, uclasses, types, locale,
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
      function readLine: string;
      function readChar: char;
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

  function TSourceCode.readLine: string;
  var
    str: string;
    ch: char;
  begin
    str := '';
    ch := readChar;
    while (ch<>C_LF) and (ch<>#0) do
    begin
      if ch<>C_CR then str := str + ch;
      ch := readChar;
    end;
    readLine := str;
  end;

  function TSourceCode.readChar: char;
  var
    result: char;
  begin
    if _sourceCount = _sourceCodeSize then  
      result := #0
    else begin
      result := _sourcePos^;
      inc(_sourcePos); 
      inc(_sourceCount);
      if result = C_LF then
      begin
        inc(_lineNumber);
        _linePosition := 1;
      end;
    end;    
    readChar := result;
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