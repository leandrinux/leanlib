unit 
  lcu;

interface

  uses
    lcommon,
    lliteral,
    lcbase,
    utils;

  procedure startBuild(const filename: string);

implementation

  procedure doStart;
  begin
    with build, stack do
    begin
      ch := readChar;
      if ch in C_SPACING_CHARS then
      begin
        pushState(stack, EStateReadInstruction);
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
        popState(stack);
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
        popState(stack);
  end;

  procedure doSkipSpaces;
  begin
    with build do
      if ch in [C_SPACE, C_TAB, C_CR] then
        ch := readChar
      else if ch = '#' then
        stack.state := EStateCommentUntilLineBreak  
      else
        popState(stack);
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
          pushState(stack, EStateReadParam0);
          state := EStateSkipSpaces;
        end else
        begin
          lineCharacter := lineCharacter - length(name) - 1;
          raise('unknown instruction "' + name + '"');
        end;
      end else
      begin
        raise('unexpected character "' + ch + '" #' + intToStr(ord(ch)));
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
          pushState(stack, EStateReadParam1);
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
    validateParams;
    build.stack.state := EStateEnd;
  end;

  procedure startBuild(const filename: string);
  begin
    initBuild(filename);
    with build, stack do
    begin
      assign(sourceFile, sourceFileName);
      {$I-} reset(build.sourceFile, 1); {$I+}
      isOpen := IOResult = 0;
      if not isOpen then raise('"' + sourceFileName + '" not found or invalid');
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