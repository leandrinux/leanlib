unit 
  lcu;

interface

  uses
    lcommon,
    lliteral,
    lcbase,
    utils;

  procedure error(const msg: string);
  procedure message(const msg: string);
  procedure initBuild(const filename: string);
  procedure startBuilding;

implementation

  const
    C_READ_BUFFER_SIZE = 1024;
    C_STATE_STACK_SIZE = 4;
    C_SPACE = ' ';
    C_CR    = #13;
    C_LF    = #10;
    C_TAB   = #09;
    C_SPACING_CHARS = [C_SPACE, C_TAB, C_LF, C_CR];

  type
    TFileBuffer = record
      data: array[0..C_READ_BUFFER_SIZE-1] of char; { data in buffer }
      size: word;                                   { how many bytes of valid data in buffer }
      position: word;                               { current position within buffer }
    end;

    EState = (                          { code parsing states}
      EStateStart,                      { parsing starts here }
      EStateEnd,                        { parsing ends here }
      EStateSkipSpacesAndLineBreaks,    { skipping empty spaces and line breaks }
      EStateSkipSpaces,                 { skipping spaces only }
      EStateReadInstruction,            { reading instruction name }
      EStateReadParam0,                 { reading first parameter }
      EStateReadParam1,                 { reading second parameter }
      EStateBuildBinaryInstruction,     { builds binary code based on collected instruction data }
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
      paramType0: EParameterType;       { type of the first parameter }
      paramType1: EParameterType;       { type of the second parameter }
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

  function validateParams(var data: TInstructionData): boolean;
  const 
    C_P0_NO_LITERAL: set of byte = 
      [C_MOV, C_ADD, C_SUB, C_MUL, C_DIV, C_SHL, C_SHR, 
       C_FADD, C_FSUB, C_FMUL, C_FDIV, C_AND, C_OR, C_NOT, 
       C_XOR, C_JMP, C_JZ, C_JP, C_JN, C_JNZ, C_CALL];
    C_P1_NO_LITERAL: set of byte = 
      [C_JE, C_JG, C_JL];
    
  var 
    paramCount: byte;
  begin
    with data do
    begin
      validateParams := false;
      paramCount := 0;

      { check the number of given parameters }
      if length(param0)>0 then inc(paramCount);
      if length(param1)>0 then inc(paramCount);
      if paramCount<>expectedParamCount then
        error('instruction ' + name + 
          ' expects ' + intToStr(expectedParamCount) + 
          ' parameters, but it got ' + intToStr(paramCount)
        );
        
      { check the parameter types are correct }
      paramType0 := guessParameterType(param0);
      paramType1 := guessParameterType(param1);
      if (opcode in C_P0_NO_LITERAL) and (paramType0 = EParameterTypeLiteral) then
        error('instruction ' + name + ' does not support a literal as first parameter');
      if (opcode in C_P1_NO_LITERAL) and (paramType1 = EParameterTypeLiteral) then
        error('instruction ' + name + ' does not support a literal as second parameter');

      validateParams := true;
    end;
  end;

  procedure doStart;
  begin
    with build, stack do
    begin
      ch := readChar;
      if ch in C_SPACING_CHARS then
      begin
        push(stack, EStateReadInstruction);
        state := EStateSkipSpacesAndLineBreaks;
      end else 
        state := EStateReadInstruction;
    end;
  end;

  procedure doCommentUntilLineBreak;
  begin
    with build do
      if ch <> C_LF then
        ch := readChar
      else
        pop(stack);
  end;

  procedure doSkipSpacesAndLineBreaks;
  begin
    with build do
      if (ch = C_LF) then
      begin
        inc(lineNumber);
        lineCharacter := 1;
        ch := readChar;
      end else if ch = '#' then
        stack.state := EStateCommentUntilLineBreak  
      else if ch in C_SPACING_CHARS then
        ch := readChar
      else
        pop(stack);
  end;

  procedure doSkipSpaces;
  begin
    with build do
      if ch in [C_SPACE, C_TAB, C_CR] then
        ch := readChar
      else if ch = '#' then
        stack.state := EStateCommentUntilLineBreak  
      else
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
      end else if ch in [C_SPACE, C_LF, #0] then
      begin
        result := getOpcodeInfoByName(name, opcode, expectedParamCount);
        if result then
        begin
          writeln(name, ': ', opcode);
          push(stack, EStateReadParam0);
          state := EStateSkipSpaces;
        end else
        begin
          lineCharacter := lineCharacter - length(name) - 1;
          error('unknown instruction "' + name + '"');
        end;
      end else
      begin
        error('unexpected character "' + ch + '" #' + intToStr(ord(ch)));
        state := EStateEnd;
      end;
  end;

  procedure doReadParam0;
  begin
    with build, instructionData, stack do
      if ch in [#0, C_CR, C_LF, ','] then
      begin
        writeln('got param0: "', param0 ,'"');
        if ch = ',' then
        begin
          ch := readChar;
          push(stack, EStateReadParam1);
          state := EStateSkipSpaces;
        end else
          state := EStateBuildBinaryInstruction;
      end else begin
        param0 := param0 + ch;
        ch := readChar;
      end;
  end;

  procedure doReadParam1;
  begin
    with build, instructionData, stack do
      if ch in [#0, C_CR, C_LF] then
      begin
        writeln('got param1: "', param1 ,'"');
        state := EStateBuildBinaryInstruction;
      end else begin
        param1 := param1 + ch;
        ch := readChar;
      end;
  end;

  procedure doBuildBinaryInstruction;
  begin
    if not validateParams(build.instructionData) then 
      build.stack.state := EStateEnd
    else 
      build.stack.state := EStateEnd;
  end;

  procedure startBuilding;
  begin
    with build, stack do
    begin
      assign(sourceFile, sourceFileName);
      {$I-} reset(build.sourceFile, 1); {$I+}
      isOpen := IOResult = 0;
      if not isOpen then error('"' + sourceFileName + '" not found or invalid');
      message('building "' + sourceFileName + '"');
      while state <> EStateEnd do
        case state of
          EStateStart: doStart;
          EStateSkipSpacesAndLineBreaks: doSkipSpacesAndLineBreaks;
          EStateReadInstruction: doReadInstruction;
          EStateReadParam0: doReadParam0;
          EStateReadParam1: doReadParam1;
          EStateSkipSpaces: doSkipSpaces;
          EStateCommentUntilLineBreak: doCommentUntilLineBreak;
          EStateBuildBinaryInstruction: doBuildBinaryInstruction;
        end;
      if state = EStateEnd then
        writeln('Ended successfully')
      else
        writeln('Ended with errors');
    end;
  end;

end.