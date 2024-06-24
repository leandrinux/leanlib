unit 
  tpunit;

interface

  const
    C_MAX_MODIFY_RECORDS = 100;
    C_MODIFY_RECORDS_FILENAME = 'MODIFY.REC';
    C_HIDE_COMPILER_OUTPUT = true;

  type
    TPath = string[50];

    TFilename = string[12];

    TModifyRecord = packed record
      filename: TFilename;
      time: longint;
    end;

    TModifyRecords = record
      recs: array [0..C_MAX_MODIFY_RECORDS - 1] of TModifyRecord;
      count: word;
    end;

  procedure error(msg: string);
  procedure log(msg: string);
  procedure buildAll(const baseDir: string);
  function getTPCPath: TPath;

implementation

  uses
    dos, execute, tpstring;

  const
    C_TPC_EXECUTABLE = 'tpc.exe';

  var 
    TPC_PATH: TPath;

  { Private }
  
  function fileExists(const path: TPath; const filename: TFilename): boolean;
  var 
    dirInfo: SearchRec;
  begin
    findFirst(path + filename, archive, dirInfo);
    fileExists := DOSError = 0;
  end;

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

  function run(const cmd, cmdLine: string; hide: boolean): integer;
  begin
    swapVectors;
    if hide then
      exec(cmd, cmdLine + '> NUL')
    else
      exec(cmd, cmdLine);
    if DOSError <> 0 then run := 1000 + DOSError else run := DOSExitCode;
    swapVectors;
  end;

  function compile(const filename: TFilename): boolean;
  begin
    compile := run(TPC_PATH + C_TPC_EXECUTABLE, filename, C_HIDE_COMPILER_OUTPUT) = 0;
  end;

  { Public }

  procedure error(msg: string);
  begin
    writeln('[X] ERROR: ', msg);
    halt(1);
  end;

  procedure log(msg: string);
  begin
    writeln('[-] ', msg);
  end;

  procedure readModifyRecords(const basedir: string; var modifyRecords: TModifyRecords);
  var
    f: file of TModifyRecord;
  begin
    assign(f, basedir + '\' + C_MODIFY_RECORDS_FILENAME);
    {$I-} reset(f); {$I+}
    if IOResult = 0 then
    begin
      with modifyRecords do
        while not eof(f) and (count<C_MAX_MODIFY_RECORDS) do 
        begin
          read(f, recs[count]);
          inc(count);
        end;
    end else
      log(C_STR_NO_MODIFIED_RECORDS);
  end;

  procedure buildAll(const baseDir: string);
  var 
    dirInfo: SearchRec;
    fileFound, compileSuccess: boolean;
    path: TPath;
    modifyRecords: TModifyRecords;
    recordCount: word;

  begin
    if length(basedir)>0 then 
      log(C_STR_PACKAGE_TO_BUILD + baseDir)
    else
      log(C_STR_PACKAGE_TO_BUILD + C_STR_CURRENT_DIR);
    log(C_STR_BUILD_ALL);

    readModifyRecords(basedir, modifyRecords);

    { start building }
    findFirst(baseDir + '\*.PAS', archive, dirInfo);
    fileFound := DOSError = 0;
    compileSuccess := true;
    while fileFound and compileSuccess do
    begin
      with dirInfo do 
      begin
        path := baseDir + '\' + name;
        compileSuccess := compile(path);
        if compileSuccess then 
          log(path + C_STR_SUCCESS)
        else 
          log(path + C_STR_FAILED);
          
      end;
      findNext(dirInfo);
      fileFound := DOSError = 0;
    end;
    if not compileSuccess then error(C_STR_BUILD_FAILED);
  end;

  function getTPCPath: TPath;
  begin
    getTPCPath := TPC_PATH;
  end;

begin
  searchPath;
end.