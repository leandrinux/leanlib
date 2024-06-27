{
  this unit's responsibility is interfacing with the
  Turbo Pascal compiler
}

unit 
  tptpc;

interface

  uses 
    tputil,
    tptexts,
    tpconfig,
    dos;

  var
    TPC_PATH: TPath;

  procedure initCompiler;
  function compile(const path: TPath; const filename: TFilename; var errorMsg: string): boolean;

implementation

  const
    C_HIDE_COMPILER_OUTPUT = false;
    C_TPC_EXECUTABLE = 'tpc.exe';
    C_TEMP_FILE = 'FILE.TMP';

  procedure searchCompilerPath;
  var
    pathvar: string;
    path: TPath;
    i: byte;
  begin
    if fileExists('.', C_TPC_EXECUTABLE) then 
    begin
      TPC_PATH := '';
      exit;
    end else
    begin
      pathVar := GetEnv('PATH');
      path := '';
      i := 1;
      while (i <= length(pathVar)) do
      begin
        if (pathVar[i] = ';') then
          if fileExists(path + '\', C_TPC_EXECUTABLE) then
          begin
            TPC_PATH := path + '\';
            exit;
          end else 
            path := ''
        else
          path := path + pathVar[i];
        inc(i);
      end;
      if (TPC_PATH = '') and fileExists(path + '\', C_TPC_EXECUTABLE) then 
        TPC_PATH := path + '\';
    end;
  end;

  function getErrorMessage: string;
  var
    f: text;
    value: string;
  begin
    assign(f, C_TEMP_FILE);
    reset(f);
    readln(f, value);
    readln(f, value);
    close(f);
    getErrorMessage := value;
  end;

  function compile(const path: TPath; const filename: TFilename; var errorMsg: string): boolean;
  var 
    cmdLine: string;
    result: boolean;
    i: byte;
  begin
    cmdLine := path + filename;
    cmdLine := cmdLine + ' -E' + BuildConfig.basedir + 'BIN'; { binaries dir }
    cmdLine := cmdLine + ' -U' + BuildConfig.basedir; { unit dir }
    cmdLine := cmdLine + ' -B';    { build all units }
    with BuildConfig.defines do for i := 0 to count-1 do cmdLine := cmdLine + ' -D' +values[i];
    cmdLine := cmdLine + ' -Q';
    cmdLine := cmdLine + ' >' + C_TEMP_FILE;
    result := run(TPC_PATH + C_TPC_EXECUTABLE, cmdLine, C_HIDE_COMPILER_OUTPUT) = 0;
    if not result then
      errorMsg := getErrorMessage
    else
      errorMsg := '';
    if result then 
      log('Building ' + path + filename + C_STR_SUCCESS)
    else begin
      log('Building ' + path + filename + C_STR_FAILED);
      log(errorMsg);
    end;
    compile := result;
    deleteFile(C_TEMP_FILE);
  end;

  procedure initCompiler;
  begin
    searchCompilerPath;
    if TPC_PATH = '' then error(C_STR_TPC_NOT_INSTALLED);  
    log(C_STR_TPC_LOCATION + TPC_PATH);
  end;

end.