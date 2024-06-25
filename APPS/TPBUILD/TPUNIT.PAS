unit 
  tpunit;

interface

  uses
    dos, tputil, tpstring;

  const
    C_HIDE_COMPILER_OUTPUT = false;

  var 
    TPC_PATH: TPath;

  procedure buildAll(const baseDir: string);

implementation

  const
    C_TPC_EXECUTABLE = 'tpc.exe';
    C_TEMP_FILE = 'FILE.TMP';
    C_DYNAMIC_UNIT_NAME = 'AUTOUNIT';

  { Private }
  
  procedure searchPath;
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

  { Public }

  procedure createDynamicUnit;
  var 
    f: text;
    h, min, s, ms: word;
    y, m, d, dw: word;
    filename, errorMsg: string;
  begin
    getTime(h,min,s,ms);
    getDate(y,m,d,dw);
    log(C_STR_DYNAMIC_UNIT_CREATE);
    filename := C_DYNAMIC_UNIT_NAME + '.PAS';
    assign(f, filename);
    rewrite(f);
    writeln(f, 'unit ', C_DYNAMIC_UNIT_NAME, ';');
    writeln(f, 'interface');
    writeln(f, 'const');
    writeln(f, '  C_BUILD_TIME = ''', h, ':', min, ':', s, '.', ms, ''';');
    writeln(f, '  C_BUILD_DATE = ''', y, '/', m, '/', d, ''';');
    writeln(f, 'implementation');
    writeln(f, 'end.');
    close(f);
    compile('.', filename, errorMsg);
  end;

  procedure deleteDynamicUnit;
  begin
    log(C_STR_DYNAMIC_UNIT_DELETE);
    deleteFile(C_DYNAMIC_UNIT_NAME + '.PAS');
    deleteFile(C_DYNAMIC_UNIT_NAME + '.TPU');
  end;

  procedure buildAll(const baseDir: string);
  var 
    dirInfo: SearchRec;
    fileFound, compileSuccess: boolean;
    path: TPath;
    previousRec, currentRec: TModifyRecords;
    recordCount: word;
    errorMsg: string;
  begin
    if length(basedir)>0 then 
      log(C_STR_PACKAGE_TO_BUILD + baseDir)
    else
      log(C_STR_PACKAGE_TO_BUILD + C_STR_CURRENT_DIR);
    log(C_STR_BUILD_ALL);

    if not directoryExists(basedir + '\BIN') then 
    begin
      createDirectory(basedir + '\BIN');
      log(C_STR_CREATED_BIN_DIR);
    end;
    readModifyRecords(basedir, previousRec);
    createDynamicUnit;

    findFirst(baseDir + '\*.PAS', archive, dirInfo);
    fileFound := DOSError = 0;
    compileSuccess := true;
    while fileFound and compileSuccess do
    begin
      with dirInfo do 
      begin
        compileSuccess := compile(baseDir, name, errorMsg);
      end;
      findNext(dirInfo);
      fileFound := DOSError = 0;
    end;
    deleteDynamicUnit;
    if compileSuccess then log(C_STR_BUILD_SUCCESS) else error(C_STR_BUILD_FAILED);
  end;

begin
  searchPath;
end.