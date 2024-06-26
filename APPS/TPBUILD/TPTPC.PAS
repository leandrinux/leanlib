{
  this unit's responsibility is interfacing with the
  Turbo Pascal compiler
}

unit 
  tptpc;

interface

  uses 
    tputil;

  var
    TPC_PATH: TPath;

  procedure searchCompilerPath;
  function compile(const path: TPath; const filename: TFilename; var errorMsg: string): boolean;
  function getErrorMessage: string;

implementation

  uses
    {$IFDEF Spanish}tpstr_es,
    {$ELSE}tpstr_en,{$ENDIF}
    dos;

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

  function compile(const path: TPath; const filename: TFilename; var errorMsg: string): boolean;
  var 
    cmdLine: string;
    result: boolean;
  begin
    cmdLine := path + '\' + filename;
    if path<>'.' then cmdLine := cmdLine + ' -E' + path + '\BIN';
    cmdLine := cmdLine + ' -Q';
    cmdLine := cmdLine + ' >' + C_TEMP_FILE;
    result := run(TPC_PATH + C_TPC_EXECUTABLE, cmdLine, C_HIDE_COMPILER_OUTPUT) = 0;
    if not result then
      errorMsg := getErrorMessage
    else
      errorMsg := '';
    if result then 
      log(path + '\' + filename + C_STR_SUCCESS)
    else begin
      log(path + '\' + filename + C_STR_FAILED);
      log(errorMsg);
    end;
    compile := result;
    deleteFile(C_TEMP_FILE);
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

begin
  searchCompilerPath;
end.