unit 
  lcu;

interface

  uses
    lcommon,
    lliteral,
    lcbase;

  procedure error(const msg: string);
  procedure message(const msg: string);
  procedure initBuild(const filename: string);
  procedure build;

implementation

  const
    C_READ_BUFFER_SIZE = 4096;

  type
    TFileBuffer = record
      data: array[0..C_READ_BUFFER_SIZE-1] of char; { data in buffer }
      size: word;                                   { how many bytes of valid data in buffer }
      position: word;                               { current position within buffer }
    end;

    TBuildInfo = record
      sourceFileName: string;           { name of the file being compiled }
      sourceFile: file;                 { source file handle }
      fileBuffer: TFileBuffer;          { data buffer used to read file }
      lineNumber: longint;              { current line number }
      instructionCount: longint;        { how many instructions have been built }
      verbose: boolean;                 { whether it should display info messages or not }
    end;

  var
    buildInfo: TBuildInfo;   

  procedure error(const msg: string);
  begin
    writeln('error: ', msg);
    halt(1);
  end;

  procedure message(const msg: string);
  begin
    writeln(msg);
  end;

  procedure initBuild(const filename: string);
  begin
    with buildInfo do
    begin
      sourceFileName := filename;
      instructionCount := 0;
      lineNumber := 1;
      verbose := true;
      fillChar(fileBuffer, sizeof(TFileBuffer), 0);
    end;
  end;

  function loadBuffer: boolean;
  begin
    loadBuffer := false;
    with buildInfo, fileBuffer do
    begin
      if eof(sourceFile) then exit;
      blockread(sourceFile, data, C_READ_BUFFER_SIZE, size);
      position := 0;
      loadBuffer := true;
    end;
  end;

  function readChar: char;
  begin
    readChar := #0;
    with buildInfo.fileBuffer do
    begin
      if (position = size) and not loadBuffer then exit;
      if size = 0 then exit;
      readChar := data[position];
      inc(position);
    end;
  end;

  function buildLine: boolean;
  var
    ch: char;
    line: string;
    result: word;
  begin
    buildLine := false;
    with buildInfo do
    begin
      ch := readChar;
      while ch <> #0 do
      begin
        ch := readChar;
      end;
    end;
  end;

  procedure build;
  begin
    with buildInfo do
    begin
      assign(sourceFile, sourceFileName);
      {$I-} reset(buildInfo.sourceFile, 1); {$I+}
      if IOResult<>0 then error('"' + sourceFileName + '" not found or invalid');
      message('building "' + sourceFileName + '"');
      while not eof(sourceFile) do
      begin
        if buildLine then inc(instructionCount);
        inc(lineNumber);
      end;
    end;
  end;

end.