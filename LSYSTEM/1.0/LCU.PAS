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
  procedure startBuilding;

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

    TInstructionData = record
      name: TInstructionName;           { the name of the instruction as written in code }
      param0: string;                   { the first parameter as written in code }
      param1: string;                   { the second parameter as written in code }
      opcode: byte;                     { the operation code that matches the specified instruction }
      expectedParamCount: byte;         { how many arguments this instruction requires }
    end;

    TBuild = record
      sourceFileName: string;           { name of the file being compiled }
      sourceFile: file;                 { source file handle }
      isOpen: boolean;                  { indicates if file is open correctly }
      ch: char;                         { the character being currently examined }
      lineNumber: longint;              { current line number }
      lineCharacter: word;              { char number being evaluated in current line }
      instructionCount: longint;        { how many instructions have been built }
      verbose: boolean;                 { whether it should display info messages or not }
      fileBuffer: TFileBuffer;          { data buffer used to read file }
      stack: TStateStack;               { stack of machine states }
      instructionData: TInstructionData { the instruction and arguments retrieved from the line }
    end;

  var
    build: TBuild;   

  procedure error(const msg: string);
  begin
    with build do
    begin
      write('error: ', msg);
      if isOpen then
        writeln(' at ln ', lineNumber,' pos ', lineCharacter)
      else
        writeln;
      halt(1);
    end;
  end;

  procedure message(const msg: string);
  begin
    writeln(msg);
  end;

  procedure initBuild(const filename: string);
  begin
    with build do
    begin
      sourceFileName := filename;
      instructionCount := 0;
      lineNumber := 1;
      lineCharacter := 1;
      verbose := true;
      fillChar(fileBuffer, sizeof(TFileBuffer), 0);
      stack.count := 0;
      stack.state := EStateStart;
      fileBuffer.position := 0;
      fileBuffer.size := 0;
      instructionData.name := '';
      instructionData.param0 := '';
      instructionData.param1 := '';
    end;
  end;

  function loadBuffer: boolean;
  begin
    loadBuffer := false;
    with build, fileBuffer do
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
    with build, fileBuffer do
    begin
      if (position = size) and not loadBuffer then exit;
      if size = 0 then exit;
      readChar := data[position];
      inc(position);
      inc(lineCharacter);
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

  procedure doStart;
  begin
    with build, stack do
    begin
      ch := readChar;
      if ch in [' ', #10, #13] then
      begin
        push(stack, EStateReadInstruction);
        state := EStateSkipSpacesAndLineBreaks;
      end else 
        state := EStateReadInstruction;
    end;
  end;

  procedure doSkipSpacesAndLineBreaks;
  begin
    with build do
      if (ch = ' ') or (ch = #13) then
        ch := readChar
      else if (ch = #10) then
      begin
        inc(lineNumber);
        lineCharacter := 1;
        ch := readChar;
      end else
        pop(stack);
  end;

  procedure doReadInstruction;
  var
    result: boolean;
  begin
    with build, instructionData, stack do
      if ch in ['a'..'z'] then
      begin 
        name := name + ch;
        ch := readChar;
      end else if ch in [' '] then
      begin
        result := getOpcodeInfoByName(name, opcode, expectedParamCount);
        if result then
        begin
          push(stack, EStateEndSuccessful);
          state := EStateSkipSpacesAndLineBreaks;
        end else
        begin
          lineCharacter := lineCharacter - length(name) - 1;
          error('unknown instruction "' + name + '"');
        end;
      end else
        state := EStateEndFailed;
  end;

  procedure startBuilding;
  const
    C_END_STATES: set of EState = [EStateEndSuccessful, EStateEndFailed];
  begin
    with build, stack do
    begin
      assign(sourceFile, sourceFileName);
      {$I-} reset(build.sourceFile, 1); {$I+}
      isOpen := IOResult = 0;
      if not isOpen then error('"' + sourceFileName + '" not found or invalid');
      message('building "' + sourceFileName + '"');
      while not (state in C_END_STATES) do
        case state of
          EStateStart: doStart;
          EStateSkipSpacesAndLineBreaks: doSkipSpacesAndLineBreaks;
          EStateReadInstruction: doReadInstruction;
        end;
      if state = EStateEndSuccessful then
        writeln('Ended successfully')
      else
        writeln('Ended with errors');
    end;
  end;

end.