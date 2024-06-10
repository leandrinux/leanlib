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
    C_READ_BUFFER_SIZE = 1024;
    C_STATE_STACK_SIZE = 4;

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

    EState = (                          { code parsing states}
      EStateStart,                      { parsing starts here }
      EStateEndSuccessful,              { parsing ended successfully }
      EStateEndFailed,                  { parsing ended with errors }
      EStateSkipSpacesAndLineBreaks,    { skipping empty spaces and line breaks }
      EStateSkipSpaces,                 { skipping spaces only }
      EStateReadInstruction,            { reading instruction name }
      EStateReadParam0,                 { reading first parameter }
      EStateReadParam1,                 { reading second parameter }
      EStateCommentUntilLineBreak,      { skipping everything until the next line break }
      EStateCommentUntilDelimiter       { skipping everything until a comment block ending tag is found }
    );

    TStateStack = record
      values: array [0..C_STATE_STACK_SIZE-1] of EState;
      count: word;
      state: EState;
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

  procedure push(var stack: TStateStack; value: EState);
  begin
    with stack do
      if stack.count = C_STATE_STACK_SIZE then
        error('State stack overflow')
      else begin
        stack.values[stack.count] := value;
        count := count + 1;
      end;
  end;

  procedure pop(var stack: TStateStack);
  begin
    with stack do
      if count = 0 then
        error('State stack empty')
      else begin
        count := count - 1;
        state := values[count];
      end;  
  end;

  procedure build;
  const
    C_END_STATES: set of EState = [EStateEndSuccessful, EStateEndFailed];
  var
    ch: char;
    stack: TStateStack;
    instructionName, param0, param1: string;
  begin
    with buildInfo, stack do
    begin
      assign(sourceFile, sourceFileName);
      {$I-} reset(buildInfo.sourceFile, 1); {$I+}
      if IOResult<>0 then error('"' + sourceFileName + '" not found or invalid');
      fileBuffer.position := 0;
      fileBuffer.size := 0;

      instructionName := '';
      param0 := '';
      param1 := '';
      count := 0;
      state := EStateStart;
      ch := readChar;
      message('building "' + sourceFileName + '"');
      while not (state in C_END_STATES) do
        case state of

          EStateStart:
          begin
            if ch in [' ', #10, #13] then
            begin
              push(stack, EStateReadInstruction);
              state := EStateSkipSpacesAndLineBreaks;
            end else 
              state := EStateReadInstruction;
          end;

          EStateSkipSpacesAndLineBreaks:
          begin
            if ch in [' ', #10, #13] then
              ch := readChar
            else
              pop(stack);
          end;

          EStateReadInstruction: 
          begin
            if ch in ['a'..'z'] then
            begin 
              instructionName := instructionName + ch;
              ch := readChar;
            end else if ch in [' '] then
            begin
              writeln('instruction: "', instructionName, '"');
              push(stack, EStateEndSuccessful);
              state := EStateSkipSpacesAndLineBreaks;
            end else
              state := EStateEndFailed;
          end;

        end;

      if state = EStateEndSuccessful then
        writeln('Ended successfully')
      else if state = EStateEndFailed then
        writeln('Ended with errors')
      else
        writeln('Unknown error');

    end;
  end;

end.