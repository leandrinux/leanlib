{
  This unit handles all the operations related
  to the build.cfg file
}
unit 
  tpconfig;
    
interface

  uses
    tputil,
    tptexts;

  const
    C_CONFIG_FILE_NAME = 'TPBUILD.CFG';
    C_CONFIG_MAX_TOKENS = 10;
    C_SKIP_CHARS = [#10, #13, ' '];
    C_CR = #13;
    C_LF = #10;

  type
    TToken = string[15];

    TTokens = record
      values: array[0..C_CONFIG_MAX_TOKENS-1] of TToken;
      count: byte;
    end;

    TBuildConfig = record
      baseDir: TPath;
      requires: TTokens;
      builds: TTokens;
      defines: TTokens;
    end;

  var
    BuildConfig: TBuildConfig;

  procedure initConfiguration(const basedir: TPath);

implementation

  var
    line, position: word;
    ch: char;
    f: text;

  procedure openConfigFile(const basedir: TPath);
  begin
    assign(f, basedir + '\' + C_CONFIG_FILE_NAME);
    {$I-} reset(f); {$I+}
    if IOResult <> 0 then error(strformat(C_STR_NO_CONFIG_FILE, C_CONFIG_FILE_NAME));
    log(C_STR_CONFIG_FILE_LOADED);
  end;

  function readChar: char;
  begin
    read(f, ch);
    inc(position);
    case ch of
      C_LF: begin
        inc(line);
        position := 1;
      end;
      C_CR: begin end;
    else
      inc(position);
    end;
  end;
  
  procedure skipSpaces;
  begin
    while not eof(f) and (ch in C_SKIP_CHARS) do readChar;
  end;

  function copyUntilCharacter(boundary: char): TToken;
  var 
    result: TToken;
  begin
    result := '';
    readChar;
    while not eof(f) and (ch <> boundary) do
    begin
      result := result + ch;
      readChar;
    end;
    copyUntilCharacter := result;
  end;

  procedure readTokens(var tokens: TTokens);
  var
    token: TToken;
  begin
    readChar;
    tokens.count := 0;
    while not eof(f) and (ch<>'[') do
    begin
      token := '';
      skipSpaces;
      while not eof(f) and (ch<>C_LF) and (ch<>'[') do 
      begin
        if ch <> C_CR then token := token + ch;  
        readChar;
      end;
      if eof(f) and (ch <> C_CR) then token := token + ch;  
      if token<>'' then
      begin
        tokens.values[tokens.count] := token;
        inc(tokens.count);
      end;
    end;
  end;

  procedure readSection(const name: TToken; var tokens: TTokens);
  var
    str: string;
  begin
    skipSpaces;
    if ch<>'[' then 
      error(
        strformat(C_STR_CFG_SYNTAX_ERROR, C_CONFIG_FILE_NAME + #0 + intToStr(line) + #0 + intToStr(position)) +
        strformat(C_STR_CFG_EXPECTS, '[' + #0 + ch)
      );
    str := copyUntilCharacter(']');
    if str<>name then error(strformat(C_STR_CFG_EXPECTS, name + #0 + str));
    readTokens(tokens);
  end;

  procedure writeTokens(const tokens:TTokens);
  var 
    i: byte;
  begin
    for i:=0 to tokens.count-1 do writeln(tokens.values[i]);
  end;
  
  procedure readConfigFile(const basedir: TPath);
  begin
    openConfigFile(basedir);
    line := 1;
    position := 0;
    readChar;
    with BuildConfig do
    begin
      readSection('requires', requires);
      readSection('builds', builds);
      readSection('defines', defines);
      if builds.count=0 then error(C_STR_NO_BUILD_SPECIFIED);
    end;
    close(f);
  end;
    
  procedure initConfiguration(const basedir: TPath);
  begin
    readConfigFile(basedir);
  end;

end.